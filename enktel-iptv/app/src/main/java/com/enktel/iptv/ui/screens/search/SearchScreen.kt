package com.enktel.iptv.ui.screens.search

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.enktel.iptv.data.model.*
import com.enktel.iptv.data.repository.ContentRepository
import com.enktel.iptv.data.repository.toContentItem
import com.enktel.iptv.ui.components.*
import com.enktel.iptv.ui.theme.EnktelColors
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SearchUiState(
    val query: String = "",
    val isSearching: Boolean = false,
    val results: List<ContentItem> = emptyList(),
    val hasSearched: Boolean = false
)

@HiltViewModel
class SearchViewModel @Inject constructor(
    private val repository: ContentRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SearchUiState())
    val uiState: StateFlow<SearchUiState> = _uiState

    private var searchJob: Job? = null

    fun updateQuery(query: String) {
        _uiState.value = _uiState.value.copy(query = query)
        searchJob?.cancel()
        if (query.length >= 2) {
            searchJob = viewModelScope.launch {
                delay(400)
                search(query)
            }
        } else {
            _uiState.value = _uiState.value.copy(results = emptyList(), hasSearched = false)
        }
    }

    private suspend fun search(query: String) {
        _uiState.value = _uiState.value.copy(isSearching = true)
        val q = query.lowercase()
        val results = mutableListOf<ContentItem>()

        repository.getMovies().getOrNull()?.let { movies ->
            movies.filter { it.name.lowercase().contains(q) }
                .take(30)
                .mapTo(results) { it.toContentItem() }
        }

        repository.getSeries().getOrNull()?.let { series ->
            series.filter { it.name.lowercase().contains(q) }
                .take(30)
                .mapTo(results) { it.toContentItem() }
        }

        repository.getLiveStreams().getOrNull()?.let { streams ->
            streams.filter { it.name.lowercase().contains(q) }
                .take(20)
                .mapTo(results) { it.toContentItem() }
        }

        _uiState.value = _uiState.value.copy(
            isSearching = false,
            results = results,
            hasSearched = true
        )
    }

    fun clearSearch() {
        _uiState.value = SearchUiState()
    }
}

@Composable
fun SearchScreen(
    onNavigateToDetail: (Int, String) -> Unit,
    onPlayStream: (Int, String, String) -> Unit,
    viewModel: SearchViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(EnktelColors.Background)
            .padding(horizontal = 16.dp)
    ) {
        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = uiState.query,
            onValueChange = { viewModel.updateQuery(it) },
            placeholder = { Text("Search movies, series, channels...") },
            leadingIcon = { Icon(Icons.Filled.Search, null) },
            trailingIcon = {
                if (uiState.query.isNotBlank()) {
                    IconButton(onClick = { viewModel.clearSearch() }) {
                        Icon(Icons.Filled.Clear, null)
                    }
                }
            },
            singleLine = true,
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(20.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = EnktelColors.Primary,
                unfocusedBorderColor = EnktelColors.GlassBorder,
                focusedContainerColor = EnktelColors.GlassWhite,
                unfocusedContainerColor = EnktelColors.GlassWhite
            )
        )

        Spacer(modifier = Modifier.height(12.dp))

        when {
            uiState.isSearching -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = EnktelColors.Primary)
                }
            }
            !uiState.hasSearched -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            Icons.Filled.Search,
                            null,
                            tint = EnktelColors.TextTertiary,
                            modifier = Modifier.size(64.dp)
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "Search across all content",
                            style = MaterialTheme.typography.bodyMedium,
                            color = EnktelColors.TextSecondary
                        )
                    }
                }
            }
            uiState.results.isEmpty() -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(Icons.Filled.SearchOff, null, tint = EnktelColors.TextTertiary, modifier = Modifier.size(48.dp))
                        Spacer(modifier = Modifier.height(8.dp))
                        Text("No results for \"${uiState.query}\"", color = EnktelColors.TextSecondary)
                    }
                }
            }
            else -> {
                Text(
                    text = "${uiState.results.size} results",
                    style = MaterialTheme.typography.labelMedium,
                    color = EnktelColors.TextTertiary
                )
                Spacer(modifier = Modifier.height(8.dp))

                LazyVerticalGrid(
                    columns = GridCells.Adaptive(minSize = 140.dp),
                    contentPadding = PaddingValues(bottom = 100.dp),
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    items(uiState.results, key = { "${it.type}_${it.id}" }) { item ->
                        ContentPosterCard(
                            item = item,
                            onClick = {
                                if (item.type == ContentType.LIVE) {
                                    onPlayStream(item.id, "live", item.name)
                                } else {
                                    onNavigateToDetail(item.id, item.type.name)
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}
