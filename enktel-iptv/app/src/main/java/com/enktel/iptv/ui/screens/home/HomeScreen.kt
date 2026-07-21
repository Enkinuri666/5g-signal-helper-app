package com.enktel.iptv.ui.screens.home

import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
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
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class HomeUiState(
    val isLoading: Boolean = true,
    val featuredItems: List<ContentItem> = emptyList(),
    val latestMovies: List<ContentItem> = emptyList(),
    val latestSeries: List<ContentItem> = emptyList(),
    val trendingMovies: List<ContentItem> = emptyList(),
    val comingSoon: List<ContentItem> = emptyList(),
    val error: String? = null
)

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val repository: ContentRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState

    init {
        loadContent()
    }

    fun loadContent() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            try {
                val moviesDeferred = async { repository.getLatestMovies(30) }
                val seriesDeferred = async { repository.getLatestSeries(30) }
                val comingSoonDeferred = async { repository.getComingSoon() }
                val allMoviesDeferred = async { repository.getMovies() }

                val latestMovies = moviesDeferred.await().getOrDefault(emptyList())
                val latestSeries = seriesDeferred.await().getOrDefault(emptyList())
                val comingSoon = comingSoonDeferred.await().getOrDefault(emptyList())
                val allMovies = allMoviesDeferred.await().getOrDefault(emptyList())

                val featured = (latestMovies.take(5).map { it.toContentItem() } +
                    latestSeries.take(5).map { it.toContentItem() })
                    .shuffled().take(5)

                val trending = allMovies
                    .sortedByDescending { it.rating5 }
                    .take(20)
                    .map { it.toContentItem() }

                _uiState.value = HomeUiState(
                    isLoading = false,
                    featuredItems = featured,
                    latestMovies = latestMovies.take(20).map { it.toContentItem() },
                    latestSeries = latestSeries.take(20).map { it.toContentItem() },
                    trendingMovies = trending,
                    comingSoon = comingSoon.take(10)
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message ?: "Failed to load content"
                )
            }
        }
    }
}

@Composable
fun HomeScreen(
    onNavigateToDetail: (Int, String) -> Unit,
    onNavigateToLatest: () -> Unit,
    onNavigateToComingSoon: () -> Unit,
    onNavigateToMovies: () -> Unit,
    onNavigateToSeries: () -> Unit,
    viewModel: HomeViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val listState = rememberLazyListState()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(EnktelColors.Background)
    ) {
        if (uiState.isLoading) {
            HomeLoadingSkeleton()
        } else if (uiState.error != null) {
            HomeError(
                message = uiState.error!!,
                onRetry = { viewModel.loadContent() }
            )
        } else {
            LazyColumn(
                state = listState,
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(bottom = 100.dp)
            ) {
                if (uiState.featuredItems.isNotEmpty()) {
                    item(key = "hero") {
                        HeroBanner(
                            item = uiState.featuredItems.first(),
                            onClick = {
                                val item = uiState.featuredItems.first()
                                onNavigateToDetail(item.id, item.type.name)
                            }
                        )
                    }
                }

                if (uiState.latestMovies.isNotEmpty()) {
                    item(key = "latest_movies_header") {
                        SectionHeader(
                            title = "Latest Movies",
                            action = "See All",
                            onActionClick = onNavigateToLatest
                        )
                    }
                    item(key = "latest_movies") {
                        ContentRow(
                            items = uiState.latestMovies,
                            onItemClick = { onNavigateToDetail(it.id, it.type.name) }
                        )
                    }
                }

                if (uiState.trendingMovies.isNotEmpty()) {
                    item(key = "trending_header") {
                        SectionHeader(title = "Trending Now")
                    }
                    item(key = "trending") {
                        ContentRow(
                            items = uiState.trendingMovies,
                            onItemClick = { onNavigateToDetail(it.id, it.type.name) }
                        )
                    }
                }

                if (uiState.latestSeries.isNotEmpty()) {
                    item(key = "latest_series_header") {
                        SectionHeader(
                            title = "Latest Series",
                            action = "See All",
                            onActionClick = onNavigateToSeries
                        )
                    }
                    item(key = "latest_series") {
                        ContentRow(
                            items = uiState.latestSeries,
                            onItemClick = { onNavigateToDetail(it.id, it.type.name) }
                        )
                    }
                }

                if (uiState.comingSoon.isNotEmpty()) {
                    item(key = "coming_soon_header") {
                        SectionHeader(
                            title = "Coming Soon",
                            action = "See All",
                            onActionClick = onNavigateToComingSoon
                        )
                    }
                    item(key = "coming_soon") {
                        ContentRow(
                            items = uiState.comingSoon,
                            onItemClick = { onNavigateToDetail(it.id, it.type.name) }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun ContentRow(
    items: List<ContentItem>,
    onItemClick: (ContentItem) -> Unit
) {
    LazyRow(
        contentPadding = PaddingValues(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        items(items, key = { "${it.type}_${it.id}" }) { item ->
            ContentPosterCard(
                item = item,
                onClick = { onItemClick(item) }
            )
        }
    }
}

@Composable
private fun HomeLoadingSkeleton() {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(bottom = 100.dp)
    ) {
        item {
            ShimmerEffect(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(420.dp)
            )
        }
        repeat(3) { section ->
            item {
                Spacer(modifier = Modifier.height(24.dp))
                ShimmerEffect(
                    modifier = Modifier
                        .padding(horizontal = 16.dp)
                        .width(180.dp)
                        .height(20.dp),
                    cornerRadius = 4.dp
                )
                Spacer(modifier = Modifier.height(12.dp))
            }
            item {
                LazyRow(
                    contentPadding = PaddingValues(horizontal = 16.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(5) {
                        ShimmerEffect(
                            modifier = Modifier
                                .width(140.dp)
                                .height(210.dp),
                            cornerRadius = 12.dp
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun HomeError(
    message: String,
    onRetry: () -> Unit
) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Icon(
                Icons.Filled.CloudOff,
                contentDescription = null,
                tint = EnktelColors.TextTertiary,
                modifier = Modifier.size(64.dp)
            )
            Text(
                text = message,
                style = MaterialTheme.typography.bodyLarge,
                color = EnktelColors.TextSecondary
            )
            Button(
                onClick = onRetry,
                colors = ButtonDefaults.buttonColors(containerColor = EnktelColors.Primary)
            ) {
                Text("Retry")
            }
        }
    }
}
