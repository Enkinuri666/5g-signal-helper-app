package com.enktel.iptv.ui.screens.detail

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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import coil.compose.AsyncImage
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

data class DetailUiState(
    val isLoading: Boolean = true,
    val item: ContentItem? = null,
    val seriesInfo: SeriesInfo? = null,
    val selectedSeason: String = "1",
    val relatedItems: List<ContentItem> = emptyList(),
    val error: String? = null
)

@HiltViewModel
class DetailViewModel @Inject constructor(
    private val repository: ContentRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val contentId: Int = savedStateHandle["contentId"] ?: 0
    private val contentType: String = savedStateHandle["contentType"] ?: "MOVIE"

    private val _uiState = MutableStateFlow(DetailUiState())
    val uiState: StateFlow<DetailUiState> = _uiState

    init {
        loadDetails()
    }

    fun loadDetails() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            try {
                when (contentType) {
                    "MOVIE" -> loadMovieDetails()
                    "SERIES" -> loadSeriesDetails()
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message ?: "Failed to load details"
                )
            }
        }
    }

    private suspend fun loadMovieDetails() {
        val movies = repository.getMovies().getOrDefault(emptyList())
        val movie = movies.find { it.streamId == contentId }

        val related = movies
            .filter { it.streamId != contentId && it.genre.isNotBlank() && it.genre == movie?.genre }
            .take(10)
            .map { it.toContentItem() }

        _uiState.value = _uiState.value.copy(
            isLoading = false,
            item = movie?.toContentItem(),
            relatedItems = related
        )
    }

    private suspend fun loadSeriesDetails() {
        val allSeries = repository.getSeries().getOrDefault(emptyList())
        val series = allSeries.find { it.seriesId == contentId }
        val seriesInfo = repository.getSeriesInfo(contentId).getOrNull()

        val related = allSeries
            .filter { it.seriesId != contentId && it.genre.isNotBlank() && it.genre == series?.genre }
            .take(10)
            .map { it.toContentItem() }

        _uiState.value = _uiState.value.copy(
            isLoading = false,
            item = series?.toContentItem(),
            seriesInfo = seriesInfo,
            relatedItems = related
        )
    }

    fun selectSeason(season: String) {
        _uiState.value = _uiState.value.copy(selectedSeason = season)
    }

    fun buildStreamUrl(streamId: Int, extension: String): String =
        repository.buildStreamUrl(streamId, extension)
}

@Composable
fun DetailScreen(
    onBack: () -> Unit,
    onPlayStream: (Int, String, String) -> Unit,
    onNavigateToDetail: (Int, String) -> Unit,
    viewModel: DetailViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(EnktelColors.Background)
    ) {
        when {
            uiState.isLoading -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = EnktelColors.Primary)
                }
            }
            uiState.error != null -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(uiState.error ?: "", color = EnktelColors.TextSecondary)
                        Button(onClick = { viewModel.loadDetails() }) { Text("Retry") }
                    }
                }
            }
            uiState.item != null -> {
                val item = uiState.item!!

                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(bottom = 100.dp)
                ) {
                    // Backdrop
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(350.dp)
                        ) {
                            AsyncImage(
                                model = item.backdropUrl.ifBlank { item.coverUrl },
                                contentDescription = item.name,
                                contentScale = ContentScale.Crop,
                                modifier = Modifier.fillMaxSize()
                            )
                            Box(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .background(
                                        Brush.verticalGradient(
                                            colors = listOf(
                                                Color.Transparent,
                                                EnktelColors.Background.copy(alpha = 0.5f),
                                                EnktelColors.Background
                                            )
                                        )
                                    )
                            )

                            IconButton(
                                onClick = onBack,
                                modifier = Modifier
                                    .align(Alignment.TopStart)
                                    .padding(16.dp)
                                    .background(
                                        EnktelColors.OverlayMedium,
                                        RoundedCornerShape(12.dp)
                                    )
                            ) {
                                Icon(Icons.Filled.ArrowBack, null, tint = Color.White)
                            }
                        }
                    }

                    // Title and metadata
                    item {
                        Column(modifier = Modifier.padding(horizontal = 16.dp)) {
                            Text(
                                text = item.name,
                                style = MaterialTheme.typography.displaySmall,
                                fontWeight = FontWeight.Black,
                                color = EnktelColors.TextPrimary
                            )

                            Spacer(modifier = Modifier.height(8.dp))

                            Row(
                                horizontalArrangement = Arrangement.spacedBy(12.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                if (item.year.isNotBlank()) {
                                    Text(item.year, style = MaterialTheme.typography.bodyMedium, color = EnktelColors.TextSecondary)
                                }
                                if (item.rating > 0) {
                                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                                        Icon(Icons.Filled.Star, null, tint = EnktelColors.GoldAccent, modifier = Modifier.size(16.dp))
                                        Text(String.format("%.1f", item.rating), style = MaterialTheme.typography.bodyMedium, color = EnktelColors.GoldAccent)
                                    }
                                }
                                if (item.genre.isNotBlank()) {
                                    Text(item.genre, style = MaterialTheme.typography.bodySmall, color = EnktelColors.TextTertiary, maxLines = 1, overflow = TextOverflow.Ellipsis)
                                }
                            }

                            Spacer(modifier = Modifier.height(16.dp))

                            // Action buttons
                            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                                Button(
                                    onClick = {
                                        if (item.type == ContentType.MOVIE) {
                                            onPlayStream(item.id, "movie", item.name)
                                        }
                                    },
                                    colors = ButtonDefaults.buttonColors(containerColor = EnktelColors.Primary),
                                    shape = RoundedCornerShape(12.dp),
                                    modifier = Modifier.weight(1f).height(48.dp)
                                ) {
                                    Icon(Icons.Filled.PlayArrow, null, modifier = Modifier.size(20.dp))
                                    Spacer(Modifier.width(4.dp))
                                    Text("Play", style = MaterialTheme.typography.titleSmall)
                                }

                                OutlinedButton(
                                    onClick = {},
                                    shape = RoundedCornerShape(12.dp),
                                    modifier = Modifier.height(48.dp)
                                ) {
                                    Icon(Icons.Filled.Add, null, modifier = Modifier.size(20.dp))
                                    Spacer(Modifier.width(4.dp))
                                    Text("My List")
                                }
                            }

                            if (item.plot.isNotBlank()) {
                                Spacer(modifier = Modifier.height(16.dp))
                                Text(item.plot, style = MaterialTheme.typography.bodyMedium, color = EnktelColors.TextSecondary)
                            }

                            if (item.cast.isNotBlank()) {
                                Spacer(modifier = Modifier.height(8.dp))
                                Text("Cast: ${item.cast}", style = MaterialTheme.typography.bodySmall, color = EnktelColors.TextTertiary)
                            }
                            if (item.director.isNotBlank()) {
                                Spacer(modifier = Modifier.height(4.dp))
                                Text("Director: ${item.director}", style = MaterialTheme.typography.bodySmall, color = EnktelColors.TextTertiary)
                            }
                        }
                    }

                    // Series episodes
                    uiState.seriesInfo?.let { info ->
                        val seasons = info.episodes.keys.sorted()
                        if (seasons.isNotEmpty()) {
                            item {
                                Spacer(modifier = Modifier.height(20.dp))
                                SectionHeader(title = "Episodes")
                                LazyRow(
                                    contentPadding = PaddingValues(horizontal = 16.dp),
                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    items(seasons) { season ->
                                        GlassPill(
                                            text = "Season $season",
                                            selected = uiState.selectedSeason == season,
                                            onClick = { viewModel.selectSeason(season) }
                                        )
                                    }
                                }
                            }

                            val episodes = info.episodes[uiState.selectedSeason] ?: emptyList()
                            items(episodes.size) { index ->
                                val episode = episodes[index]
                                GlassCard(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(horizontal = 16.dp, vertical = 4.dp),
                                    cornerRadius = 12.dp,
                                    onClick = {
                                        onPlayStream(
                                            episode.id.toIntOrNull() ?: 0,
                                            "series",
                                            "${item.name} S${uiState.selectedSeason}E${episode.episodeNum}"
                                        )
                                    }
                                ) {
                                    Row(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .padding(12.dp),
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                                    ) {
                                        Box(
                                            modifier = Modifier
                                                .size(48.dp)
                                                .background(EnktelColors.Primary.copy(alpha = 0.2f), RoundedCornerShape(8.dp)),
                                            contentAlignment = Alignment.Center
                                        ) {
                                            Text(
                                                text = "${episode.episodeNum}",
                                                style = MaterialTheme.typography.titleMedium,
                                                fontWeight = FontWeight.Bold,
                                                color = EnktelColors.Primary
                                            )
                                        }
                                        Column(modifier = Modifier.weight(1f)) {
                                            Text(
                                                text = episode.title.ifBlank { "Episode ${episode.episodeNum}" },
                                                style = MaterialTheme.typography.titleSmall,
                                                color = EnktelColors.TextPrimary,
                                                maxLines = 1
                                            )
                                            episode.info?.let { epInfo ->
                                                if (epInfo.duration.isNotBlank()) {
                                                    Text(epInfo.duration, style = MaterialTheme.typography.labelSmall, color = EnktelColors.TextTertiary)
                                                }
                                            }
                                        }
                                        Icon(Icons.Filled.PlayCircle, null, tint = EnktelColors.Primary, modifier = Modifier.size(28.dp))
                                    }
                                }
                            }
                        }
                    }

                    // Related content
                    if (uiState.relatedItems.isNotEmpty()) {
                        item {
                            Spacer(modifier = Modifier.height(20.dp))
                            SectionHeader(title = "More Like This")
                        }
                        item {
                            LazyRow(
                                contentPadding = PaddingValues(horizontal = 16.dp),
                                horizontalArrangement = Arrangement.spacedBy(12.dp)
                            ) {
                                items(uiState.relatedItems, key = { "${it.type}_${it.id}" }) { related ->
                                    ContentPosterCard(
                                        item = related,
                                        onClick = { onNavigateToDetail(related.id, related.type.name) }
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
