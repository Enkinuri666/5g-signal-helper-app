package com.enktel.iptv

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.*
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.*
import androidx.navigation.navArgument
import com.enktel.iptv.data.repository.ContentRepository
import com.enktel.iptv.ui.components.GlassBottomBar
import com.enktel.iptv.ui.components.GlassNavItem
import com.enktel.iptv.ui.navigation.Screen
import com.enktel.iptv.ui.navigation.bottomNavItems
import com.enktel.iptv.ui.screens.comingsoon.ComingSoonScreen
import com.enktel.iptv.ui.screens.detail.DetailScreen
import com.enktel.iptv.ui.screens.home.HomeScreen
import com.enktel.iptv.ui.screens.latest.LatestReleasesScreen
import com.enktel.iptv.ui.screens.login.LoginScreen
import com.enktel.iptv.ui.screens.movies.MoviesScreen
import com.enktel.iptv.ui.screens.player.PlayerScreen
import com.enktel.iptv.ui.screens.search.SearchScreen
import com.enktel.iptv.ui.screens.series.SeriesScreen
import com.enktel.iptv.ui.screens.settings.SettingsScreen
import com.enktel.iptv.ui.screens.sports.SportsHubScreen
import com.enktel.iptv.ui.theme.EnktelTheme
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject
    lateinit var repository: ContentRepository

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            EnktelTheme {
                EnktelApp(repository = repository)
            }
        }
    }
}

@Composable
fun EnktelApp(repository: ContentRepository) {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    val showBottomBar = currentRoute in listOf(
        Screen.Home.route,
        Screen.SportsHub.route,
        Screen.Movies.route,
        Screen.Series.route,
        Screen.Search.route,
        Screen.LatestReleases.route,
        Screen.ComingSoon.route,
        Screen.Settings.route
    )

    Box(modifier = Modifier.fillMaxSize()) {
        NavHost(
            navController = navController,
            startDestination = Screen.Login.route,
            modifier = Modifier.fillMaxSize(),
            enterTransition = { fadeIn(tween(300)) },
            exitTransition = { fadeOut(tween(300)) }
        ) {
            composable(Screen.Login.route) {
                LoginScreen(
                    onLoginSuccess = {
                        navController.navigate(Screen.Home.route) {
                            popUpTo(Screen.Login.route) { inclusive = true }
                        }
                    }
                )
            }

            composable(Screen.Home.route) {
                HomeScreen(
                    onNavigateToDetail = { id, type ->
                        navController.navigate(Screen.Detail.createRoute(id, type))
                    },
                    onNavigateToLatest = {
                        navController.navigate(Screen.LatestReleases.route)
                    },
                    onNavigateToComingSoon = {
                        navController.navigate(Screen.ComingSoon.route)
                    },
                    onNavigateToMovies = {
                        navController.navigate(Screen.Movies.route)
                    },
                    onNavigateToSeries = {
                        navController.navigate(Screen.Series.route)
                    }
                )
            }

            composable(Screen.SportsHub.route) {
                SportsHubScreen(
                    onPlayStream = { id, type, title ->
                        navController.navigate(Screen.Player.createRoute(id, type, title))
                    }
                )
            }

            composable(Screen.Movies.route) {
                MoviesScreen(
                    onNavigateToDetail = { id, type ->
                        navController.navigate(Screen.Detail.createRoute(id, type))
                    },
                    onPlayStream = { id, type, title ->
                        navController.navigate(Screen.Player.createRoute(id, type, title))
                    }
                )
            }

            composable(Screen.Series.route) {
                SeriesScreen(
                    onNavigateToDetail = { id, type ->
                        navController.navigate(Screen.Detail.createRoute(id, type))
                    }
                )
            }

            composable(Screen.LatestReleases.route) {
                LatestReleasesScreen(
                    onNavigateToDetail = { id, type ->
                        navController.navigate(Screen.Detail.createRoute(id, type))
                    }
                )
            }

            composable(Screen.ComingSoon.route) {
                ComingSoonScreen(
                    onNavigateToDetail = { id, type ->
                        navController.navigate(Screen.Detail.createRoute(id, type))
                    }
                )
            }

            composable(Screen.Search.route) {
                SearchScreen(
                    onNavigateToDetail = { id, type ->
                        navController.navigate(Screen.Detail.createRoute(id, type))
                    },
                    onPlayStream = { id, type, title ->
                        navController.navigate(Screen.Player.createRoute(id, type, title))
                    }
                )
            }

            composable(Screen.Settings.route) {
                SettingsScreen(
                    repository = repository,
                    onLogout = {
                        navController.navigate(Screen.Login.route) {
                            popUpTo(0) { inclusive = true }
                        }
                    }
                )
            }

            composable(
                route = Screen.Detail.route,
                arguments = listOf(
                    navArgument("contentId") { type = NavType.IntType },
                    navArgument("contentType") { type = NavType.StringType }
                )
            ) {
                DetailScreen(
                    onBack = { navController.popBackStack() },
                    onPlayStream = { id, type, title ->
                        navController.navigate(Screen.Player.createRoute(id, type, title))
                    },
                    onNavigateToDetail = { id, type ->
                        navController.navigate(Screen.Detail.createRoute(id, type))
                    }
                )
            }

            composable(
                route = Screen.Player.route,
                arguments = listOf(
                    navArgument("streamId") { type = NavType.IntType },
                    navArgument("streamType") { type = NavType.StringType },
                    navArgument("title") { type = NavType.StringType }
                )
            ) {
                PlayerScreen(
                    onBack = { navController.popBackStack() }
                )
            }
        }

        // Glass bottom navigation bar
        if (showBottomBar) {
            GlassBottomBar(
                modifier = Modifier.align(androidx.compose.ui.Alignment.BottomCenter)
            ) {
                bottomNavItems.forEach { item ->
                    val selected = currentRoute == item.screen.route
                    GlassNavItem(
                        icon = if (selected) item.selectedIcon else item.unselectedIcon,
                        label = item.label,
                        selected = selected,
                        onClick = {
                            if (currentRoute != item.screen.route) {
                                navController.navigate(item.screen.route) {
                                    popUpTo(Screen.Home.route) { saveState = true }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            }
                        }
                    )
                }

                // Additional menu items
                GlassNavItem(
                    icon = androidx.compose.material.icons.Icons.Outlined.Settings,
                    label = "More",
                    selected = currentRoute == Screen.Settings.route,
                    onClick = {
                        navController.navigate(Screen.Settings.route) {
                            popUpTo(Screen.Home.route) { saveState = true }
                            launchSingleTop = true
                            restoreState = true
                        }
                    }
                )
            }
        }
    }
}
