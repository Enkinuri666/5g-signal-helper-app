package com.enktel.iptv.data.repository

import com.enktel.iptv.data.api.ApiClient
import com.enktel.iptv.data.api.XtreamApi
import com.enktel.iptv.data.model.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ContentRepository @Inject constructor() {

    private var api: XtreamApi? = null
    private var credentials: AppCredentials = AppCredentials()
    private val mutex = Mutex()

    private val _connectionState = MutableStateFlow<ConnectionState>(ConnectionState.Disconnected)
    val connectionState: StateFlow<ConnectionState> = _connectionState

    private var cachedMovies: List<VodStream>? = null
    private var cachedSeries: List<SeriesStream>? = null
    private var cachedLiveStreams: List<LiveStream>? = null
    private var cachedMovieCategories: List<Category>? = null
    private var cachedSeriesCategories: List<Category>? = null
    private var cachedLiveCategories: List<Category>? = null
    private var cachedServerInfo: ServerInfo? = null

    suspend fun connect(creds: AppCredentials): Result<ServerInfo> = withContext(Dispatchers.IO) {
        mutex.withLock {
            try {
                _connectionState.value = ConnectionState.Connecting
                credentials = creds
                api = ApiClient.createApi(creds.serverUrl)
                val info = api!!.authenticate(creds.username, creds.password)
                cachedServerInfo = info

                if (info.userInfo?.status != "Active") {
                    _connectionState.value = ConnectionState.Error("Account is not active")
                    return@withContext Result.failure(Exception("Account is not active"))
                }

                _connectionState.value = ConnectionState.Connected(info)
                clearCache()
                Result.success(info)
            } catch (e: Exception) {
                _connectionState.value = ConnectionState.Error(e.message ?: "Connection failed")
                Result.failure(e)
            }
        }
    }

    fun disconnect() {
        api = null
        credentials = AppCredentials()
        _connectionState.value = ConnectionState.Disconnected
        clearCache()
    }

    private fun clearCache() {
        cachedMovies = null
        cachedSeries = null
        cachedLiveStreams = null
        cachedMovieCategories = null
        cachedSeriesCategories = null
        cachedLiveCategories = null
    }

    private fun requireApi(): XtreamApi =
        api ?: throw IllegalStateException("Not connected to server")

    suspend fun getMovieCategories(): Result<List<Category>> = safeCall {
        cachedMovieCategories ?: requireApi()
            .getVodCategories(credentials.username, credentials.password)
            .also { cachedMovieCategories = it }
    }

    suspend fun getMovies(categoryId: String? = null): Result<List<VodStream>> = safeCall {
        if (categoryId != null) {
            requireApi().getVodStreams(credentials.username, credentials.password, categoryId = categoryId)
        } else {
            cachedMovies ?: requireApi()
                .getVodStreams(credentials.username, credentials.password)
                .also { cachedMovies = it }
        }
    }

    suspend fun getSeriesCategories(): Result<List<Category>> = safeCall {
        cachedSeriesCategories ?: requireApi()
            .getSeriesCategories(credentials.username, credentials.password)
            .also { cachedSeriesCategories = it }
    }

    suspend fun getSeries(categoryId: String? = null): Result<List<SeriesStream>> = safeCall {
        if (categoryId != null) {
            requireApi().getSeries(credentials.username, credentials.password, categoryId = categoryId)
        } else {
            cachedSeries ?: requireApi()
                .getSeries(credentials.username, credentials.password)
                .also { cachedSeries = it }
        }
    }

    suspend fun getSeriesInfo(seriesId: Int): Result<SeriesInfo> = safeCall {
        requireApi().getSeriesInfo(credentials.username, credentials.password, seriesId = seriesId)
    }

    suspend fun getLiveCategories(): Result<List<Category>> = safeCall {
        cachedLiveCategories ?: requireApi()
            .getLiveCategories(credentials.username, credentials.password)
            .also { cachedLiveCategories = it }
    }

    suspend fun getLiveStreams(categoryId: String? = null): Result<List<LiveStream>> = safeCall {
        if (categoryId != null) {
            requireApi().getLiveStreams(credentials.username, credentials.password, categoryId = categoryId)
        } else {
            cachedLiveStreams ?: requireApi()
                .getLiveStreams(credentials.username, credentials.password)
                .also { cachedLiveStreams = it }
        }
    }

    suspend fun getEpg(streamId: Int): Result<List<EpgListing>> = safeCall {
        val response = requireApi().getEpg(credentials.username, credentials.password, streamId = streamId)
        response.values.flatten()
    }

    suspend fun getLatestMovies(limit: Int = 50): Result<List<VodStream>> = safeCall {
        val all = cachedMovies ?: requireApi()
            .getVodStreams(credentials.username, credentials.password)
            .also { cachedMovies = it }

        all.sortedByDescending { it.added?.toLongOrNull() ?: 0L }.take(limit)
    }

    suspend fun getLatestSeries(limit: Int = 50): Result<List<SeriesStream>> = safeCall {
        val all = cachedSeries ?: requireApi()
            .getSeries(credentials.username, credentials.password)
            .also { cachedSeries = it }

        all.sortedByDescending { it.added?.toLongOrNull() ?: 0L }.take(limit)
    }

    suspend fun getComingSoon(): Result<List<ContentItem>> = safeCall {
        val now = System.currentTimeMillis() / 1000
        val movies = cachedMovies ?: requireApi()
            .getVodStreams(credentials.username, credentials.password)
            .also { cachedMovies = it }

        val series = cachedSeries ?: requireApi()
            .getSeries(credentials.username, credentials.password)
            .also { cachedSeries = it }

        val upcoming = mutableListOf<ContentItem>()

        movies.filter { movie ->
            val addedTs = movie.added?.toLongOrNull() ?: 0L
            addedTs > now || movie.year.toIntOrNull()?.let { it > 2025 } == true
        }.mapTo(upcoming) { it.toContentItem() }

        series.filter { s ->
            val addedTs = s.added?.toLongOrNull() ?: 0L
            addedTs > now || s.year.toIntOrNull()?.let { it > 2025 } == true
        }.mapTo(upcoming) { it.toContentItem() }

        upcoming.sortedBy { it.addedTimestamp }
    }

    suspend fun getSportsStreams(): Result<List<LiveStream>> = safeCall {
        val categories = cachedLiveCategories ?: requireApi()
            .getLiveCategories(credentials.username, credentials.password)
            .also { cachedLiveCategories = it }

        val sportsCategories = categories.filter { cat ->
            val name = cat.categoryName.lowercase()
            name.contains("sport") || name.contains("football") ||
            name.contains("soccer") || name.contains("nba") ||
            name.contains("nfl") || name.contains("mlb") ||
            name.contains("ufc") || name.contains("boxing") ||
            name.contains("cricket") || name.contains("rugby") ||
            name.contains("tennis") || name.contains("f1") ||
            name.contains("racing") || name.contains("hockey") ||
            name.contains("wrestling") || name.contains("ppv") ||
            name.contains("fight") || name.contains("espn") ||
            name.contains("sky sport") || name.contains("bein") ||
            name.contains("dazn") || name.contains("bt sport")
        }

        val streams = mutableListOf<LiveStream>()
        for (cat in sportsCategories) {
            try {
                val catStreams = requireApi().getLiveStreams(
                    credentials.username, credentials.password, categoryId = cat.categoryId
                )
                streams.addAll(catStreams)
            } catch (_: Exception) { }
        }
        streams.distinctBy { it.streamId }
    }

    fun buildStreamUrl(streamId: Int, extension: String = "ts"): String {
        val base = credentials.serverUrl.trimEnd('/')
        return "$base/${credentials.username}/${credentials.password}/$streamId.$extension"
    }

    fun buildLiveStreamUrl(streamId: Int): String {
        val base = credentials.serverUrl.trimEnd('/')
        return "$base/live/${credentials.username}/${credentials.password}/$streamId.m3u8"
    }

    fun getCredentials(): AppCredentials = credentials

    private suspend fun <T> safeCall(block: suspend () -> T): Result<T> =
        withContext(Dispatchers.IO) {
            try {
                Result.success(block())
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
}

fun VodStream.toContentItem() = ContentItem(
    id = streamId,
    name = name,
    coverUrl = streamIcon,
    year = year,
    rating = rating5,
    genre = genre,
    plot = plot,
    addedTimestamp = added?.toLongOrNull() ?: 0L,
    type = ContentType.MOVIE,
    containerExtension = containerExtension,
    releaseDate = releaseDate,
    cast = cast,
    director = director,
    categoryId = categoryId
)

fun SeriesStream.toContentItem() = ContentItem(
    id = seriesId,
    name = name,
    coverUrl = cover,
    year = year,
    rating = rating5,
    genre = genre,
    plot = plot,
    addedTimestamp = added?.toLongOrNull() ?: 0L,
    type = ContentType.SERIES,
    releaseDate = releaseDate,
    cast = cast,
    director = director,
    backdropUrl = backdropPath.firstOrNull() ?: "",
    categoryId = categoryId
)

fun LiveStream.toContentItem() = ContentItem(
    id = streamId,
    name = name,
    coverUrl = streamIcon,
    type = ContentType.LIVE,
    addedTimestamp = added?.toLongOrNull() ?: 0L,
    categoryId = categoryId
)

sealed class ConnectionState {
    data object Disconnected : ConnectionState()
    data object Connecting : ConnectionState()
    data class Connected(val serverInfo: ServerInfo) : ConnectionState()
    data class Error(val message: String) : ConnectionState()
}
