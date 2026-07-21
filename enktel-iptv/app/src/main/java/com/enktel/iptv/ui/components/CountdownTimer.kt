package com.enktel.iptv.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.enktel.iptv.ui.theme.EnktelColors
import kotlinx.coroutines.delay

@Composable
fun CountdownTimer(
    targetTimestamp: Long,
    modifier: Modifier = Modifier
) {
    var timeLeft by remember { mutableStateOf(calculateTimeLeft(targetTimestamp)) }

    LaunchedEffect(targetTimestamp) {
        while (true) {
            timeLeft = calculateTimeLeft(targetTimestamp)
            delay(1000)
        }
    }

    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(6.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        CountdownUnit(value = timeLeft.days, label = "DAYS")
        CountdownSeparator()
        CountdownUnit(value = timeLeft.hours, label = "HRS")
        CountdownSeparator()
        CountdownUnit(value = timeLeft.minutes, label = "MIN")
        CountdownSeparator()
        CountdownUnit(value = timeLeft.seconds, label = "SEC")
    }
}

@Composable
private fun CountdownUnit(
    value: Int,
    label: String
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(2.dp)
    ) {
        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(8.dp))
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            EnktelColors.Primary.copy(alpha = 0.3f),
                            EnktelColors.Primary.copy(alpha = 0.1f)
                        )
                    )
                )
                .padding(horizontal = 10.dp, vertical = 6.dp),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = String.format("%02d", value),
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = EnktelColors.TextPrimary
            )
        }
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = EnktelColors.TextTertiary
        )
    }
}

@Composable
private fun CountdownSeparator() {
    val infiniteTransition = rememberInfiniteTransition(label = "blink")
    val alpha by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 0.3f,
        animationSpec = infiniteRepeatable(
            animation = tween(500),
            repeatMode = RepeatMode.Reverse
        ),
        label = "separator_blink"
    )

    Text(
        text = ":",
        style = MaterialTheme.typography.titleMedium,
        fontWeight = FontWeight.Bold,
        color = EnktelColors.Primary.copy(alpha = alpha)
    )
}

private data class TimeLeft(
    val days: Int = 0,
    val hours: Int = 0,
    val minutes: Int = 0,
    val seconds: Int = 0
)

private fun calculateTimeLeft(targetTimestamp: Long): TimeLeft {
    val now = System.currentTimeMillis() / 1000
    val diff = (targetTimestamp - now).coerceAtLeast(0)

    val days = (diff / 86400).toInt()
    val hours = ((diff % 86400) / 3600).toInt()
    val minutes = ((diff % 3600) / 60).toInt()
    val seconds = (diff % 60).toInt()

    return TimeLeft(days, hours, minutes, seconds)
}
