package com.enktel.iptv.ui.screens.latest

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
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
import kotlinx.coroutines.async
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*
import javax.inject.Inject

data class LatestReleasesUiState(
    val isLoading: Boolean = true,
    val latestMovies: List<ContentItem> = emptyList(),
    val latestSeries: List<ContentItem> = emptyList(),
    val selectedTab: Int = 0,
    val lastUpdated: String = "",
    val error: String? = null
)

@HiltViewModel
class LatestReleasesViewModel @Inject constructor(
    private val repository: ContentRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(LatestReleasesUiState())
    val uiState: StateFlow<LatestReleasesUiState> = _uiState

    private val dateFormat = SimpleDateFormat("MMM dd, yyyy HH:mm", Locale.getDefault())

    init {
        loadLatest()
        startAutoRefresh()
    }

    fun loadLatest() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            try {
                val moviesDeferred = async { repository.getLatestMovies(100) }
                val seriesDeferred = async { repository.getLatestSeries(100) }

                val movies = moviesDeferred.await().getOrDefault(emptyList()).map { it.toContentItem() }
                val series = seriesDeferred.await().getOrDefault(emptyList()).map { it.toContentItem() }

                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    latestMovies = movies,
                    latestSeries = series,
                    lastUpdated = dateFormat.format(Date())
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message ?: "Failed to load latest releases"
                )
            }
        }
    }

    private fun startAutoRefresh() {
        viewModelScope.launch {
            while (isActive) {
                delay(24 * 60 * 60 * 1000L)
                loadLatest()
            }
        }
    }

    fun selectTab(index: Int) {
        _uiState.value = _uiState.value.copy(selectedTab = index)
    }
}

@Composable
fun LatestReleasesScreen(
    onNavigateToDetail: (Int, String) -> Unit,
    viewModel: LatestReleasesViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val tabs = listOf("Movies", "Series")

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(EnktelColors.Background)
    ) {
        // Header with gradient
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            EnktelColors.Primary.copy(alpha = 0.12f),
                            EnktelColors.Background
                        )
                    )
                )
                .padding(horizontal = 16.dp, vertical = 16.dp)
        ) {
            Column {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            text = "Latest Releases",
                            style = MaterialTheme.typography.displaySmall,
                            fontWeight = FontWeight.Black,
                            color = EnktelColors.TextPrimary
                        )
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Icon(
                                Icons.Filled.AutoAwesome,
                                contentDescription = null,
                                tint = EnktelColors.GoldAccent,
                                modifier = Modifier.size(14.dp)
                            )
                            Text(
                                text = "Auto-updates daily",
                                style = MaterialTheme.typography.labelSmall,
                                color = EnktelColors.GoldAccent
                            )
                        }
                    }
                    IconButton(onClick = { viewModel.loadLatest() }) {
                        Icon(
                            Icons.Filled.Refresh,
                            contentDescription = "Refresh",
                            tint = EnktelColors.TextSecondary
                        )
                    }
                }

                if (uiState.lastUpdated.isNotBlank()) {
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "Last updated: ${uiState.lastUpdated}",
                        style = MaterialTheme.typography.labelSmall,
                        color = EnktelColors.TextTertiary
                    )
                }

                Spacer(modifier = Modifier.height(12.dp))

                // Tab row
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    tabs.forEachIndexed { index, tab ->
                        GlassPill(
                            text = tab,
                            selected = uiState.selectedTab == index,
                            onClick = { viewModel.selectTab(index) }
                        )
                    }
                }
            }
        }

        when {
            uiState.isLoading -> {
                LazyColumn(
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(8) {
                        ShimmerEffect(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(120.dp),
                            cornerRadius = 12.dp
                        )
                    }
                }
            }
            uiState.error != null -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Icon(Icons.Filled.NewReleases, null, tint = EnktelColors.TextTertiary, modifier = Modifier.size(48.dp))
                        Text(uiState.error ?: "", color = EnktelColors.TextSecondary)
                        Button(
                            onClick = { viewModel.loadLatest() },
                            colors = ButtonDefaults.buttonColors(containerColor = EnktelColors.Primary)
                        ) { Text("Retry") }
                    }
                }
            }
            else -> {
                val items = if (uiState.selectedTab == 0) uiState.latestMovies
                else uiState.latestSeries

                if (items.isEmpty()) {
                    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Text("No recent releases found", color = EnktelColors.TextSecondary)
                    }
                } else {
                    LazyColumn(
                        contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = 100.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        // Featured row at top
                        item {
                            SectionHeader(title = "Just Added")
                            Spacer(modifier = Modifier.height(4.dp))
                            LazyRow(
                                horizontalArrangement = Arrangement.spacedBy(12.dp)
                            ) {
                                items(items.take(10), key = { "${it.type}_${it.id}" }) { item ->
                                    ContentPosterCard(
                                        item = item,
                                        onClick = { onNavigateToDetail(item.id, item.type.name) }
                                    )
                                }
                            }
                        }

                        item { Spacer(modifier = Modifier.height(8.dp)) }
                        item { SectionHeader(title = "All Recent") }

                        items(items.drop(10), key = { "${it.type}_${it.id}_wide" }) { item ->
                            ContentWideCard(
                                item = item,
                                onClick = { onNavigateToDetail(item.id, item.type.name) }
                            )
                        }
                    }
                }
            }
        }
    }
}
