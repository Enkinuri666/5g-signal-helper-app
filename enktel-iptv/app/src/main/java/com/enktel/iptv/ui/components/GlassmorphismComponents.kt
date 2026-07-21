package com.enktel.iptv.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.enktel.iptv.ui.theme.EnktelColors

@Composable
fun GlassCard(
    modifier: Modifier = Modifier,
    cornerRadius: Dp = 16.dp,
    onClick: (() -> Unit)? = null,
    content: @Composable BoxScope.() -> Unit
) {
    val shape = RoundedCornerShape(cornerRadius)
    Box(
        modifier = modifier
            .clip(shape)
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        EnktelColors.GlassWhite,
                        EnktelColors.GlassHighlight
                    )
                )
            )
            .border(
                width = 0.5.dp,
                brush = Brush.linearGradient(
                    colors = listOf(
                        EnktelColors.GlassBorder,
                        Color.Transparent,
                        EnktelColors.GlassBorder.copy(alpha = 0.1f)
                    )
                ),
                shape = shape
            )
            .then(
                if (onClick != null) Modifier.clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = ripple(color = EnktelColors.Primary),
                    onClick = onClick
                ) else Modifier
            ),
        content = content
    )
}

@Composable
fun GlassBottomBar(
    modifier: Modifier = Modifier,
    content: @Composable RowScope.() -> Unit
) {
    val shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
    Box(
        modifier = modifier
            .fillMaxWidth()
            .clip(shape)
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        EnktelColors.Surface.copy(alpha = 0.85f),
                        EnktelColors.Background.copy(alpha = 0.95f)
                    )
                )
            )
            .border(
                width = 0.5.dp,
                brush = Brush.verticalGradient(
                    colors = listOf(EnktelColors.GlassBorder, Color.Transparent)
                ),
                shape = shape
            )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 8.dp, vertical = 8.dp),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically,
            content = content
        )
    }
}

@Composable
fun GlassNavItem(
    icon: ImageVector,
    label: String,
    selected: Boolean,
    onClick: () -> Unit
) {
    val color = if (selected) EnktelColors.Primary else EnktelColors.TextSecondary
    Column(
        modifier = Modifier
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onClick
            )
            .padding(horizontal = 12.dp, vertical = 6.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(2.dp)
    ) {
        Box {
            if (selected) {
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .align(Alignment.Center)
                        .background(
                            EnktelColors.Primary.copy(alpha = 0.15f),
                            CircleShape
                        )
                )
            }
            Icon(
                imageVector = icon,
                contentDescription = label,
                tint = color,
                modifier = Modifier
                    .size(24.dp)
                    .align(Alignment.Center)
            )
        }
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = color
        )
    }
}

@Composable
fun GlassPill(
    text: String,
    modifier: Modifier = Modifier,
    selected: Boolean = false,
    onClick: () -> Unit = {}
) {
    val bg = if (selected) EnktelColors.Primary.copy(alpha = 0.3f) else EnktelColors.GlassWhite
    val borderColor = if (selected) EnktelColors.Primary else EnktelColors.GlassBorder
    val textColor = if (selected) EnktelColors.Primary else EnktelColors.TextSecondary

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(20.dp))
            .background(bg)
            .border(0.5.dp, borderColor, RoundedCornerShape(20.dp))
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = ripple(color = EnktelColors.Primary),
                onClick = onClick
            )
            .padding(horizontal = 16.dp, vertical = 8.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.labelMedium,
            color = textColor
        )
    }
}

@Composable
fun SectionHeader(
    title: String,
    modifier: Modifier = Modifier,
    action: String? = null,
    onActionClick: () -> Unit = {}
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.headlineMedium,
            color = EnktelColors.TextPrimary
        )
        if (action != null) {
            Text(
                text = action,
                style = MaterialTheme.typography.labelLarge,
                color = EnktelColors.Primary,
                modifier = Modifier.clickable(onClick = onActionClick)
            )
        }
    }
}

@Composable
fun LiveBadge(modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .background(EnktelColors.LiveRed, RoundedCornerShape(4.dp))
            .padding(horizontal = 6.dp, vertical = 2.dp)
    ) {
        Text(
            text = "LIVE",
            style = MaterialTheme.typography.labelSmall,
            color = Color.White
        )
    }
}

@Composable
fun ShimmerEffect(
    modifier: Modifier = Modifier,
    cornerRadius: Dp = 12.dp
) {
    val shimmerAnim = rememberInfiniteTransition(label = "shimmer")
    val progress = shimmerAnim.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(1200, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "shimmer_progress"
    )

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(cornerRadius))
            .drawBehind {
                val shimmerWidth = size.width * 0.4f
                val offset = progress.value * (size.width + shimmerWidth) - shimmerWidth
                drawRect(EnktelColors.Shimmer)
                drawRect(
                    brush = Brush.linearGradient(
                        colors = listOf(
                            Color.Transparent,
                            EnktelColors.ShimmerHighlight,
                            Color.Transparent
                        ),
                        start = Offset(offset, 0f),
                        end = Offset(offset + shimmerWidth, size.height)
                    )
                )
            }
    )
}

@Composable
fun GradientOverlay(
    modifier: Modifier = Modifier,
    colors: List<Color> = listOf(Color.Transparent, EnktelColors.Background)
) {
    Box(
        modifier = modifier.background(Brush.verticalGradient(colors))
    )
}

@Composable
fun RatingBar(
    rating: Double,
    modifier: Modifier = Modifier
) {
    Row(modifier = modifier, horizontalArrangement = Arrangement.spacedBy(2.dp)) {
        repeat(5) { index ->
            val starRating = rating / 2.0
            val filled = index < starRating.toInt()
            val halfFilled = !filled && index < starRating + 0.5
            Box(
                modifier = Modifier
                    .size(12.dp)
                    .background(
                        if (filled || halfFilled) EnktelColors.RatingStarFilled
                        else EnktelColors.RatingStarEmpty,
                        CircleShape
                    )
            )
        }
    }
}
