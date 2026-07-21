package com.enktel.iptv.ui.theme

import android.app.Activity
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val EnktelDarkColorScheme = darkColorScheme(
    primary = EnktelColors.Primary,
    onPrimary = EnktelColors.TextOnPrimary,
    primaryContainer = EnktelColors.PrimaryVariant,
    secondary = EnktelColors.Secondary,
    onSecondary = EnktelColors.TextOnPrimary,
    secondaryContainer = EnktelColors.SecondaryVariant,
    tertiary = EnktelColors.Tertiary,
    background = EnktelColors.Background,
    onBackground = EnktelColors.TextPrimary,
    surface = EnktelColors.Surface,
    onSurface = EnktelColors.TextPrimary,
    surfaceVariant = EnktelColors.SurfaceVariant,
    onSurfaceVariant = EnktelColors.TextSecondary,
    outline = EnktelColors.GlassBorder,
    outlineVariant = EnktelColors.Divider
)

@Composable
fun EnktelTheme(content: @Composable () -> Unit) {
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = EnktelColors.Background.toArgb()
            window.navigationBarColor = EnktelColors.Background.toArgb()
            WindowCompat.getInsetsController(window, view).apply {
                isAppearanceLightStatusBars = false
                isAppearanceLightNavigationBars = false
            }
        }
    }

    MaterialTheme(
        colorScheme = EnktelDarkColorScheme,
        typography = EnktelTypography,
        content = content
    )
}
