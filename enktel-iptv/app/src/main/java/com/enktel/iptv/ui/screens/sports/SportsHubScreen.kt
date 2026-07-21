package com.enktel.iptv.ui.screens.sports

import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
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
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import coil.compose.AsyncImage
import com.enktel.iptv.data.model.*
import com.enktel.iptv.data.repository.ContentRepository
import com.enktel.iptv.ui.components.*
import com.enktel.iptv.ui.theme.EnktelColors
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SportsCategory(
    val name: String,
    val icon: String,
    val keywords: List<String>
)

val sportsCategoryFilters = listOf(
    SportsCategory("All", "", listOf()),
    SportsCategory("Football", "football", listOf("football", "soccer", "premier", "la liga", "serie a", "bundesliga", "champions", "europa")),
    SportsCategory("Basketball", "basketball", listOf("nba", "basketball", "euroleague")),
    SportsCategory("American Football", "american_football", listOf("nfl", "american football", "ncaa")),
    SportsCategory("Baseball", "baseball", listOf("mlb", "baseball")),
    SportsCategory("Hockey", "hockey", listOf("nhl", "hockey")),
    SportsCategory("Tennis", "tennis", listOf("tennis", "atp", "wta")),
    SportsCategory("MMA/Boxing", "fighting", listOf("ufc", "mma", "boxing", "fight", "ppv", "wrestling", "wwe")),
    SportsCategory("Cricket", "cricket", listOf("cricket", "ipl")),
    SportsCategory("Motorsport", "motorsport", listOf("f1", "formula", "racing", "motogp", "nascar")),
    SportsCategory("Rugby", "rugby", listOf("rugby"))
)

data class SportsUiState(
    val isLoading: Boolean = true,
    val streams: List<LiveStream> = emptyList(),
    val filteredStreams: List<LiveStream> = emptyList(),
    val selectedCategory: Int = 0,
    val searchQuery: String = "",
    val viewMode: SportsViewMode = SportsViewMode.GRID,
    val error: String? = null
)

enum class SportsViewMode { GRID, LIST }

@HiltViewModel
class SportsHubViewModel @Inject constructor(
    private val repository: ContentRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SportsUiState())
    val uiState: StateFlow<SportsUiState> = _uiState

    init {
        loadSportsStreams()
    }

    fun loadSportsStreams() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            try {
                val result = repository.getSportsStreams()
                val streams = result.getOrThrow()
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    streams = streams,
                    filteredStreams = streams
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message ?: "Failed to load sports channels"
                )
            }
        }
    }

    fun selectCategory(index: Int) {
        _uiState.value = _uiState.value.copy(selectedCategory = index)
        applyFilters()
    }

    fun updateSearch(query: String) {
        _uiState.value = _uiState.value.copy(searchQuery = query)
        applyFilters()
    }

    fun toggleViewMode() {
        val current = _uiState.value.viewMode
        _uiState.value = _uiState.value.copy(
            viewMode = if (current == SportsViewMode.GRID) SportsViewMode.LIST else SportsViewMode.GRID
        )
    }

    private fun applyFilters() {
        val state = _uiState.value
        val category = sportsCategoryFilters[state.selectedCategory]

        var filtered = state.streams
        if (category.keywords.isNotEmpty()) {
            filtered = filtered.filter { stream ->
                val name = stream.name.lowercase()
                category.keywords.any { name.contains(it) }
            }
        }
        if (state.searchQuery.isNotBlank()) {
            val q = state.searchQuery.lowercase()
            filtered = filtered.filter { it.name.lowercase().contains(q) }
        }
        _uiState.value = state.copy(filteredStreams = filtered)
    }

    fun buildStreamUrl(streamId: Int): String =
        repository.buildLiveStreamUrl(streamId)
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SportsHubScreen(
    onPlayStream: (Int, String, String) -> Unit,
    viewModel: SportsHubViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(EnktelColors.Background)
    ) {
        // Sports Hub Header
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            EnktelColors.SportGreen.copy(alpha = 0.15f),
                            EnktelColors.Background
                        )
                    )
                )
                .padding(top = 16.dp, bottom = 8.dp)
        ) {
            Column(modifier = Modifier.padding(horizontal = 16.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            text = "SportsHub",
                            style = MaterialTheme.typography.displaySmall,
                            fontWeight = FontWeight.Black,
                            color = EnktelColors.TextPrimary
                        )
                        Text(
                            text = "Live Sports Streaming",
                            style = MaterialTheme.typography.bodySmall,
                            color = EnktelColors.SportGreen
                        )
                    }

                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        IconButton(
                            onClick = { viewModel.toggleViewMode() }
                        ) {
                            Icon(
                                imageVector = if (uiState.viewMode == SportsViewMode.GRID)
                                    Icons.Filled.ViewList else Icons.Filled.GridView,
                                contentDescription = "Toggle view",
                                tint = EnktelColors.TextSecondary
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(12.dp))

                // Search bar
                OutlinedTextField(
                    value = uiState.searchQuery,
                    onValueChange = { viewModel.updateSearch(it) },
                    placeholder = { Text("Search sports channels...") },
                    leadingIcon = {
                        Icon(Icons.Filled.Search, contentDescription = null)
                    },
                    trailingIcon = {
                        if (uiState.searchQuery.isNotBlank()) {
                            IconButton(onClick = { viewModel.updateSearch("") }) {
                                Icon(Icons.Filled.Clear, contentDescription = null)
                            }
                        }
                    },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(16.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = EnktelColors.SportGreen,
                        unfocusedBorderColor = EnktelColors.GlassBorder,
                        focusedContainerColor = EnktelColors.GlassWhite,
                        unfocusedContainerColor = EnktelColors.GlassWhite
                    )
                )

                Spacer(modifier = Modifier.height(12.dp))

                // Category filter chips
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    itemsIndexed(sportsCategoryFilters) { index, category ->
                        GlassPill(
                            text = category.name,
                            selected = uiState.selectedCategory == index,
                            onClick = { viewModel.selectCategory(index) }
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(8.dp))

        // Content area
        when {
            uiState.isLoading -> {
                SportsLoadingSkeleton()
            }
            uiState.error != null -> {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Icon(
                            Icons.Filled.SportsScore,
                            contentDescription = null,
                            tint = EnktelColors.TextTertiary,
                            modifier = Modifier.size(48.dp)
                        )
                        Text(
                            text = uiState.error ?: "",
                            style = MaterialTheme.typography.bodyMedium,
                            color = EnktelColors.TextSecondary
                        )
                        Button(
                            onClick = { viewModel.loadSportsStreams() },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = EnktelColors.SportGreen
                            )
                        ) {
                            Text("Retry")
                        }
                    }
                }
            }
            uiState.filteredStreams.isEmpty() -> {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            Icons.Filled.SearchOff,
                            contentDescription = null,
                            tint = EnktelColors.TextTertiary,
                            modifier = Modifier.size(48.dp)
                        )
                        Text(
                            text = "No channels found",
                            style = MaterialTheme.typography.bodyMedium,
                            color = EnktelColors.TextSecondary
                        )
                    }
                }
            }
            else -> {
                AnimatedContent(
                    targetState = uiState.viewMode,
                    transitionSpec = {
                        fadeIn(tween(300)) togetherWith fadeOut(tween(300))
                    },
                    label = "view_mode"
                ) { viewMode ->
                    when (viewMode) {
                        SportsViewMode.GRID -> SportsGrid(
                            streams = uiState.filteredStreams,
                            onPlayStream = onPlayStream
                        )
                        SportsViewMode.LIST -> SportsList(
                            streams = uiState.filteredStreams,
                            onPlayStream = onPlayStream
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun SportsGrid(
    streams: List<LiveStream>,
    onPlayStream: (Int, String, String) -> Unit
) {
    LazyVerticalGrid(
        columns = GridCells.Adaptive(minSize = 155.dp),
        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp),
        modifier = Modifier.fillMaxSize()
    ) {
        items(streams, key = { it.streamId }) { stream ->
            SportsGridCard(
                stream = stream,
                onClick = { onPlayStream(stream.streamId, "live", stream.name) }
            )
        }
    }
}

@Composable
private fun SportsGridCard(
    stream: LiveStream,
    onClick: () -> Unit
) {
    GlassCard(
        modifier = Modifier
            .fillMaxWidth()
            .height(130.dp),
        cornerRadius = 14.dp,
        onClick = onClick
    ) {
        Box(modifier = Modifier.fillMaxSize()) {
            if (stream.streamIcon.isNotBlank()) {
                AsyncImage(
                    model = stream.streamIcon,
                    contentDescription = stream.name,
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
                                    EnktelColors.OverlayDark
                                )
                            )
                        )
                )
            } else {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(
                            Brush.linearGradient(
                                colors = listOf(
                                    EnktelColors.SportGreen.copy(alpha = 0.2f),
                                    EnktelColors.SportBlue.copy(alpha = 0.2f)
                                )
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Filled.SportsSoccer,
                        contentDescription = null,
                        tint = EnktelColors.TextTertiary,
                        modifier = Modifier.size(32.dp)
                    )
                }
            }

            Column(
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(10.dp)
            ) {
                Text(
                    text = stream.name,
                    style = MaterialTheme.typography.labelMedium,
                    color = EnktelColors.TextPrimary,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
            }

            LiveBadge(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(8.dp)
            )

            // Play icon overlay
            Box(
                modifier = Modifier
                    .align(Alignment.Center)
                    .size(36.dp)
                    .background(
                        EnktelColors.SportGreen.copy(alpha = 0.8f),
                        CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    Icons.Filled.PlayArrow,
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}

@Composable
private fun SportsList(
    streams: List<LiveStream>,
    onPlayStream: (Int, String, String) -> Unit
) {
    LazyColumn(
        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
        modifier = Modifier.fillMaxSize()
    ) {
        items(streams, key = { it.streamId }) { stream ->
            SportsListCard(
                stream = stream,
                onClick = { onPlayStream(stream.streamId, "live", stream.name) }
            )
        }
    }
}

@Composable
private fun SportsListCard(
    stream: LiveStream,
    onClick: () -> Unit
) {
    GlassCard(
        modifier = Modifier
            .fillMaxWidth()
            .height(72.dp),
        cornerRadius = 12.dp,
        onClick = onClick
    ) {
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            if (stream.streamIcon.isNotBlank()) {
                AsyncImage(
                    model = stream.streamIcon,
                    contentDescription = stream.name,
                    contentScale = ContentScale.Fit,
                    modifier = Modifier
                        .size(48.dp)
                        .clip(RoundedCornerShape(8.dp))
                )
            } else {
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .background(
                            EnktelColors.SportGreen.copy(alpha = 0.2f),
                            RoundedCornerShape(8.dp)
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Filled.SportsSoccer,
                        contentDescription = null,
                        tint = EnktelColors.SportGreen,
                        modifier = Modifier.size(24.dp)
                    )
                }
            }

            Text(
                text = stream.name,
                style = MaterialTheme.typography.titleSmall,
                color = EnktelColors.TextPrimary,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f)
            )

            LiveBadge()

            Icon(
                Icons.Filled.PlayCircle,
                contentDescription = "Play",
                tint = EnktelColors.SportGreen,
                modifier = Modifier.size(32.dp)
            )
        }
    }
}

@Composable
private fun SportsLoadingSkeleton() {
    LazyVerticalGrid(
        columns = GridCells.Adaptive(minSize = 155.dp),
        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp),
        modifier = Modifier.fillMaxSize()
    ) {
        items(12) {
            ShimmerEffect(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(130.dp),
                cornerRadius = 14.dp
            )
        }
    }
}
