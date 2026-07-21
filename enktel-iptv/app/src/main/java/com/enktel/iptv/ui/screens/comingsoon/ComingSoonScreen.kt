package com.enktel.iptv.ui.screens.comingsoon

import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
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
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import coil.compose.AsyncImage
import com.enktel.iptv.data.model.*
import com.enktel.iptv.data.repository.ContentRepository
import com.enktel.iptv.ui.components.*
import com.enktel.iptv.ui.theme.EnktelColors
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import javax.inject.Inject

data class ComingSoonUiState(
    val isLoading: Boolean = true,
    val items: List<ContentItem> = emptyList(),
    val error: String? = null
)

@HiltViewModel
class ComingSoonViewModel @Inject constructor(
    private val repository: ContentRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(ComingSoonUiState())
    val uiState: StateFlow<ComingSoonUiState> = _uiState

    init {
        loadComingSoon()
        startAutoRefresh()
    }

    fun loadComingSoon() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            try {
                val result = repository.getComingSoon()
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    items = result.getOrDefault(emptyList())
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message ?: "Failed to load coming soon content"
                )
            }
        }
    }

    private fun startAutoRefresh() {
        viewModelScope.launch {
            while (isActive) {
                delay(24 * 60 * 60 * 1000L)
                loadComingSoon()
            }
        }
    }
}

@Composable
fun ComingSoonScreen(
    onNavigateToDetail: (Int, String) -> Unit,
    viewModel: ComingSoonViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(EnktelColors.Background)
    ) {
        // Header
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            EnktelColors.Tertiary.copy(alpha = 0.12f),
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
                            text = "Coming Soon",
                            style = MaterialTheme.typography.displaySmall,
                            fontWeight = FontWeight.Black,
                            color = EnktelColors.TextPrimary
                        )
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Icon(
                                Icons.Filled.Schedule,
                                contentDescription = null,
                                tint = EnktelColors.Tertiary,
                                modifier = Modifier.size(14.dp)
                            )
                            Text(
                                text = "Auto-updates daily from Eagle 4K",
                                style = MaterialTheme.typography.labelSmall,
                                color = EnktelColors.Tertiary
                            )
                        }
                    }
                    IconButton(onClick = { viewModel.loadComingSoon() }) {
                        Icon(
                            Icons.Filled.Refresh,
                            contentDescription = "Refresh",
                            tint = EnktelColors.TextSecondary
                        )
                    }
                }
            }
        }

        when {
            uiState.isLoading -> {
                LazyColumn(
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    items(6) {
                        ShimmerEffect(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(200.dp),
                            cornerRadius = 16.dp
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
                        Icon(Icons.Filled.Upcoming, null, tint = EnktelColors.TextTertiary, modifier = Modifier.size(48.dp))
                        Text(uiState.error ?: "", color = EnktelColors.TextSecondary)
                        Button(
                            onClick = { viewModel.loadComingSoon() },
                            colors = ButtonDefaults.buttonColors(containerColor = EnktelColors.Tertiary)
                        ) { Text("Retry") }
                    }
                }
            }
            uiState.items.isEmpty() -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(Icons.Filled.EventBusy, null, tint = EnktelColors.TextTertiary, modifier = Modifier.size(48.dp))
                        Spacer(modifier = Modifier.height(8.dp))
                        Text("No upcoming releases found", color = EnktelColors.TextSecondary)
                    }
                }
            }
            else -> {
                LazyColumn(
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                    modifier = Modifier.fillMaxSize()
                ) {
                    items(uiState.items, key = { "${it.type}_${it.id}" }) { item ->
                        ComingSoonCard(
                            item = item,
                            onClick = { onNavigateToDetail(item.id, item.type.name) }
                        )
                    }

                    item {
                        Spacer(modifier = Modifier.height(80.dp))
                    }
                }
            }
        }
    }
}

@Composable
private fun ComingSoonCard(
    item: ContentItem,
    onClick: () -> Unit
) {
    GlassCard(
        modifier = Modifier.fillMaxWidth(),
        cornerRadius = 16.dp,
        onClick = onClick
    ) {
        Column {
            // Backdrop image
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(180.dp)
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
                                    EnktelColors.CardSurface
                                )
                            )
                        )
                )

                // Type badge
                Box(
                    modifier = Modifier
                        .align(Alignment.TopStart)
                        .padding(12.dp)
                        .background(
                            EnktelColors.Tertiary.copy(alpha = 0.8f),
                            RoundedCornerShape(6.dp)
                        )
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                ) {
                    Text(
                        text = if (item.type == ContentType.MOVIE) "MOVIE" else "SERIES",
                        style = MaterialTheme.typography.labelSmall,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }

                // Countdown timer
                Box(
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(12.dp)
                ) {
                    CountdownTimer(
                        targetTimestamp = item.addedTimestamp.coerceAtLeast(
                            System.currentTimeMillis() / 1000 + 86400
                        )
                    )
                }
            }

            // Info section
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(EnktelColors.CardSurface)
                    .padding(16.dp)
            ) {
                Text(
                    text = item.name,
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    color = EnktelColors.TextPrimary,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.height(6.dp))

                Row(
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    if (item.year.isNotBlank()) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Icon(Icons.Filled.CalendarMonth, null, tint = EnktelColors.TextTertiary, modifier = Modifier.size(14.dp))
                            Text(item.year, style = MaterialTheme.typography.bodySmall, color = EnktelColors.TextSecondary)
                        }
                    }
                    if (item.genre.isNotBlank()) {
                        Text(
                            text = item.genre.split(",").take(3).joinToString(" | "),
                            style = MaterialTheme.typography.bodySmall,
                            color = EnktelColors.TextTertiary,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }

                if (item.plot.isNotBlank()) {
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = item.plot,
                        style = MaterialTheme.typography.bodySmall,
                        color = EnktelColors.TextSecondary,
                        maxLines = 3,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                if (item.cast.isNotBlank()) {
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        text = "Cast: ${item.cast}",
                        style = MaterialTheme.typography.labelSmall,
                        color = EnktelColors.TextTertiary,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        }
    }
}
