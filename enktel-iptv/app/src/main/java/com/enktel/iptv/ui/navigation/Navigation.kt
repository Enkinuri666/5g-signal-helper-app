package com.enktel.iptv.ui.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.ui.graphics.vector.ImageVector

sealed class Screen(val route: String) {
    data object Login : Screen("login")
    data object Home : Screen("home")
    data object Movies : Screen("movies")
    data object Series : Screen("series")
    data object SportsHub : Screen("sports")
    data object LatestReleases : Screen("latest")
    data object ComingSoon : Screen("coming_soon")
    data object Search : Screen("search")
    data object Settings : Screen("settings")
    data object Player : Screen("player/{streamId}/{streamType}/{title}") {
        fun createRoute(streamId: Int, streamType: String, title: String) =
            "player/$streamId/$streamType/${java.net.URLEncoder.encode(title, "UTF-8")}"
    }
    data object Detail : Screen("detail/{contentId}/{contentType}") {
        fun createRoute(contentId: Int, contentType: String) =
            "detail/$contentId/$contentType"
    }
}

data class BottomNavItem(
    val screen: Screen,
    val label: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector
)

val bottomNavItems = listOf(
    BottomNavItem(Screen.Home, "Home", Icons.Filled.Home, Icons.Outlined.Home),
    BottomNavItem(Screen.SportsHub, "Sports", Icons.Filled.SportsSoccer, Icons.Outlined.SportsSoccer),
    BottomNavItem(Screen.Movies, "Movies", Icons.Filled.Movie, Icons.Outlined.Movie),
    BottomNavItem(Screen.Series, "Series", Icons.Filled.Tv, Icons.Outlined.Tv),
    BottomNavItem(Screen.Search, "Search", Icons.Filled.Search, Icons.Outlined.Search)
)
