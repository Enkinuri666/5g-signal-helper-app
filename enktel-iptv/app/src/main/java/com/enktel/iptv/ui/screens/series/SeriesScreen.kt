package com.enktel.iptv.ui.screens.series

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.*
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
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SeriesUiState(
    val isLoading: Boolean = true,
    val categories: List<Category> = emptyList(),
    val series: List<ContentItem> = emptyList(),
    val filteredSeries: List<ContentItem> = emptyList(),
    val selectedCategory: String = "all",
    val selectedSort: SortOption = SortOption.DEFAULT,
    val searchQuery: String = "",
    val error: String? = null
)

@HiltViewModel
class SeriesViewModel @Inject constructor(
    private val repository: ContentRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SeriesUiState())
    val uiState: StateFlow<SeriesUiState> = _uiState

    init {
        loadSeries()
    }

    fun loadSeries() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            try {
                val categories = repository.getSeriesCategories().getOrDefault(emptyList())
                val series = repository.getSeries().getOrDefault(emptyList())
                    .map { it.toContentItem() }

                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    categories = categories,
                    series = series,
                    filteredSeries = series
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message ?: "Failed to load series"
                )
            }
        }
    }

    fun selectCategory(categoryId: String) {
        _uiState.value = _uiState.value.copy(selectedCategory = categoryId)
        applyFilters()
    }

    fun selectSort(sort: SortOption) {
        _uiState.value = _uiState.value.copy(selectedSort = sort)
        applyFilters()
    }

    fun updateSearch(query: String) {
        _uiState.value = _uiState.value.copy(searchQuery = query)
        applyFilters()
    }

    private fun applyFilters() {
        val state = _uiState.value
        var filtered = state.series

        if (state.selectedCategory != "all") {
            filtered = filtered.filter { it.categoryId == state.selectedCategory }
        }

        if (state.searchQuery.isNotBlank()) {
            val q = state.searchQuery.lowercase()
            filtered = filtered.filter { it.name.lowercase().contains(q) }
        }

        filtered = when (state.selectedSort) {
            SortOption.NAME_ASC -> filtered.sortedBy { it.name.lowercase() }
            SortOption.NAME_DESC -> filtered.sortedByDescending { it.name.lowercase() }
            SortOption.YEAR_2026 -> filtered.filter { it.year == "2026" }
            SortOption.YEAR_DESC -> filtered.sortedByDescending { it.year.toIntOrNull() ?: 0 }
            SortOption.YEAR_ASC -> filtered.sortedBy { it.year.toIntOrNull() ?: 9999 }
            SortOption.RATING_DESC -> filtered.sortedByDescending { it.rating }
            SortOption.RATING_ASC -> filtered.sortedBy { it.rating }
            SortOption.RECENTLY_ADDED -> filtered.sortedByDescending { it.addedTimestamp }
            SortOption.DEFAULT -> filtered
        }

        _uiState.value = state.copy(filteredSeries = filtered)
    }
}

@Composable
fun SeriesScreen(
    onNavigateToDetail: (Int, String) -> Unit,
    viewModel: SeriesViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var showSortMenu by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(EnktelColors.Background)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Series",
                    style = MaterialTheme.typography.displaySmall,
                    color = EnktelColors.TextPrimary
                )

                Box {
                    IconButton(onClick = { showSortMenu = true }) {
                        Icon(
                            Icons.Filled.Sort,
                            contentDescription = "Sort",
                            tint = if (uiState.selectedSort != SortOption.DEFAULT)
                                EnktelColors.Primary else EnktelColors.TextSecondary
                        )
                    }
                    DropdownMenu(
                        expanded = showSortMenu,
                        onDismissRequest = { showSortMenu = false },
                        containerColor = EnktelColors.Surface
                    ) {
                        SortOption.entries.forEach { option ->
                            DropdownMenuItem(
                                text = {
                                    Text(
                                        text = option.label,
                                        color = if (uiState.selectedSort == option)
                                            EnktelColors.Primary else EnktelColors.TextPrimary
                                    )
                                },
                                onClick = {
                                    viewModel.selectSort(option)
                                    showSortMenu = false
                                },
                                leadingIcon = if (uiState.selectedSort == option) {
                                    { Icon(Icons.Filled.Check, null, tint = EnktelColors.Primary) }
                                } else null
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            OutlinedTextField(
                value = uiState.searchQuery,
                onValueChange = { viewModel.updateSearch(it) },
                placeholder = { Text("Search series...") },
                leadingIcon = { Icon(Icons.Filled.Search, null) },
                trailingIcon = {
                    if (uiState.searchQuery.isNotBlank()) {
                        IconButton(onClick = { viewModel.updateSearch("") }) {
                            Icon(Icons.Filled.Clear, null)
                        }
                    }
                },
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = EnktelColors.Primary,
                    unfocusedBorderColor = EnktelColors.GlassBorder,
                    focusedContainerColor = EnktelColors.GlassWhite,
                    unfocusedContainerColor = EnktelColors.GlassWhite
                )
            )

            Spacer(modifier = Modifier.height(8.dp))

            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                item {
                    GlassPill(
                        text = "All",
                        selected = uiState.selectedCategory == "all",
                        onClick = { viewModel.selectCategory("all") }
                    )
                }
                items(uiState.categories) { cat ->
                    GlassPill(
                        text = cat.categoryName,
                        selected = uiState.selectedCategory == cat.categoryId,
                        onClick = { viewModel.selectCategory(cat.categoryId) }
                    )
                }
            }

            if (uiState.selectedSort == SortOption.YEAR_2026) {
                Spacer(modifier = Modifier.height(8.dp))
                GlassCard(modifier = Modifier.fillMaxWidth(), cornerRadius = 12.dp) {
                    Row(
                        modifier = Modifier.padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(Icons.Filled.CalendarMonth, null, tint = EnktelColors.GoldAccent, modifier = Modifier.size(20.dp))
                        Text(
                            "Showing ${uiState.filteredSeries.size} series from 2026",
                            style = MaterialTheme.typography.labelMedium,
                            color = EnktelColors.GoldAccent
                        )
                    }
                }
            }
        }

        when {
            uiState.isLoading -> {
                LazyVerticalGrid(
                    columns = GridCells.Adaptive(minSize = 140.dp),
                    contentPadding = PaddingValues(horizontal = 12.dp),
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    items(12) {
                        ShimmerEffect(modifier = Modifier.fillMaxWidth().height(210.dp), cornerRadius = 12.dp)
                    }
                }
            }
            uiState.error != null -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Icon(Icons.Filled.ErrorOutline, null, tint = EnktelColors.TextTertiary, modifier = Modifier.size(48.dp))
                        Text(uiState.error ?: "", color = EnktelColors.TextSecondary)
                        Button(onClick = { viewModel.loadSeries() }, colors = ButtonDefaults.buttonColors(containerColor = EnktelColors.Primary)) { Text("Retry") }
                    }
                }
            }
            uiState.filteredSeries.isEmpty() -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(Icons.Filled.Tv, null, tint = EnktelColors.TextTertiary, modifier = Modifier.size(48.dp))
                        Spacer(modifier = Modifier.height(8.dp))
                        Text("No series found", color = EnktelColors.TextSecondary)
                    }
                }
            }
            else -> {
                LazyVerticalGrid(
                    columns = GridCells.Adaptive(minSize = 140.dp),
                    contentPadding = PaddingValues(start = 12.dp, end = 12.dp, bottom = 100.dp),
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    items(uiState.filteredSeries, key = { it.id }) { series ->
                        ContentPosterCard(item = series, onClick = { onNavigateToDetail(series.id, "SERIES") })
                    }
                }
            }
        }
    }
}
