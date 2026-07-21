package com.enktel.iptv.ui.screens.player

import android.app.Activity
import android.content.pm.ActivityInfo
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.viewinterop.AndroidView
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView
import com.enktel.iptv.data.repository.ContentRepository
import com.enktel.iptv.ui.theme.EnktelColors
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import java.net.URLDecoder
import javax.inject.Inject

data class PlayerUiState(
    val streamUrl: String = "",
    val title: String = "",
    val isPlaying: Boolean = false,
    val isBuffering: Boolean = true,
    val showControls: Boolean = true,
    val error: String? = null
)

@HiltViewModel
class PlayerViewModel @Inject constructor(
    private val repository: ContentRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val streamId: Int = savedStateHandle["streamId"] ?: 0
    private val streamType: String = savedStateHandle["streamType"] ?: "live"
    val title: String = try {
        URLDecoder.decode(savedStateHandle["title"] ?: "", "UTF-8")
    } catch (_: Exception) {
        savedStateHandle["title"] ?: ""
    }

    private val _uiState = MutableStateFlow(PlayerUiState())
    val uiState: StateFlow<PlayerUiState> = _uiState

    init {
        buildUrl()
    }

    private fun buildUrl() {
        val url = when (streamType) {
            "live" -> repository.buildLiveStreamUrl(streamId)
            "movie" -> repository.buildStreamUrl(streamId, "mkv")
            "series" -> repository.buildStreamUrl(streamId, "mkv")
            else -> repository.buildStreamUrl(streamId, "ts")
        }
        _uiState.value = PlayerUiState(streamUrl = url, title = title)
    }

    fun onError(message: String) {
        _uiState.value = _uiState.value.copy(error = message, isBuffering = false)
    }

    fun onPlaying() {
        _uiState.value = _uiState.value.copy(isPlaying = true, isBuffering = false, error = null)
    }

    fun onBuffering() {
        _uiState.value = _uiState.value.copy(isBuffering = true)
    }

    fun toggleControls() {
        _uiState.value = _uiState.value.copy(showControls = !_uiState.value.showControls)
    }
}

@Composable
fun PlayerScreen(
    onBack: () -> Unit,
    viewModel: PlayerViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current

    DisposableEffect(Unit) {
        val activity = context as? Activity
        activity?.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE

        onDispose {
            activity?.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
    ) {
        if (uiState.streamUrl.isNotBlank()) {
            var player by remember { mutableStateOf<ExoPlayer?>(null) }

            DisposableEffect(uiState.streamUrl) {
                val exoPlayer = ExoPlayer.Builder(context).build().apply {
                    val mediaItem = MediaItem.fromUri(uiState.streamUrl)
                    setMediaItem(mediaItem)
                    playWhenReady = true
                    addListener(object : Player.Listener {
                        override fun onPlaybackStateChanged(state: Int) {
                            when (state) {
                                Player.STATE_READY -> viewModel.onPlaying()
                                Player.STATE_BUFFERING -> viewModel.onBuffering()
                                Player.STATE_ENDED -> {}
                                Player.STATE_IDLE -> {}
                            }
                        }
                        override fun onPlayerError(error: PlaybackException) {
                            viewModel.onError(error.message ?: "Playback error")
                        }
                    })
                    prepare()
                }
                player = exoPlayer

                onDispose {
                    exoPlayer.release()
                    player = null
                }
            }

            player?.let { exo ->
                AndroidView(
                    factory = { ctx ->
                        PlayerView(ctx).apply {
                            this.player = exo
                            useController = true
                            layoutParams = FrameLayout.LayoutParams(
                                ViewGroup.LayoutParams.MATCH_PARENT,
                                ViewGroup.LayoutParams.MATCH_PARENT
                            )
                        }
                    },
                    modifier = Modifier.fillMaxSize()
                )
            }
        }

        // Buffering indicator
        if (uiState.isBuffering) {
            CircularProgressIndicator(
                modifier = Modifier
                    .align(Alignment.Center)
                    .size(48.dp),
                color = EnktelColors.Primary,
                strokeWidth = 3.dp
            )
        }

        // Error overlay
        if (uiState.error != null) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.8f)),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(Icons.Filled.Error, null, tint = EnktelColors.LiveRed, modifier = Modifier.size(48.dp))
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(uiState.error ?: "", color = Color.White, style = MaterialTheme.typography.bodyMedium)
                    Spacer(modifier = Modifier.height(16.dp))
                    Button(onClick = onBack, colors = ButtonDefaults.buttonColors(containerColor = EnktelColors.Primary)) {
                        Text("Go Back")
                    }
                }
            }
        }

        // Title bar
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .align(Alignment.TopStart)
                .background(
                    Brush.verticalGradient(
                        colors = listOf(Color.Black.copy(alpha = 0.7f), Color.Transparent)
                    )
                )
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(
                onClick = onBack,
                modifier = Modifier
                    .background(Color.White.copy(alpha = 0.1f), CircleShape)
            ) {
                Icon(Icons.Filled.ArrowBack, null, tint = Color.White)
            }
            Spacer(modifier = Modifier.width(12.dp))
            Text(
                text = uiState.title,
                style = MaterialTheme.typography.titleMedium,
                color = Color.White,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}
