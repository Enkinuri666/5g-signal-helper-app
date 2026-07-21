package com.enktel.iptv.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ServerInfo(
    @SerialName("user_info") val userInfo: UserInfo? = null,
    @SerialName("server_info") val serverInfo: ServerDetails? = null
)

@Serializable
data class UserInfo(
    val username: String = "",
    val password: String = "",
    val status: String = "",
    @SerialName("exp_date") val expDate: String? = null,
    @SerialName("is_trial") val isTrial: String = "0",
    @SerialName("active_cons") val activeCons: String = "0",
    @SerialName("created_at") val createdAt: String = "",
    @SerialName("max_connections") val maxConnections: String = "1",
    @SerialName("allowed_output_formats") val allowedFormats: List<String> = emptyList()
)

@Serializable
data class ServerDetails(
    val url: String = "",
    val port: String = "",
    @SerialName("https_port") val httpsPort: String = "",
    @SerialName("server_protocol") val protocol: String = "http",
    @SerialName("rtmp_port") val rtmpPort: String = "",
    @SerialName("timezone") val timezone: String = "",
    @SerialName("timestamp_now") val timestampNow: Long = 0,
    @SerialName("time_now") val timeNow: String = ""
)

@Serializable
data class Category(
    @SerialName("category_id") val categoryId: String = "",
    @SerialName("category_name") val categoryName: String = "",
    @SerialName("parent_id") val parentId: Int = 0
)

@Serializable
data class LiveStream(
    @SerialName("num") val num: Int = 0,
    val name: String = "",
    @SerialName("stream_type") val streamType: String = "",
    @SerialName("stream_id") val streamId: Int = 0,
    @SerialName("stream_icon") val streamIcon: String = "",
    @SerialName("epg_channel_id") val epgChannelId: String? = null,
    val added: String? = null,
    @SerialName("custom_sid") val customSid: String? = null,
    @SerialName("tv_archive") val tvArchive: Int = 0,
    @SerialName("direct_source") val directSource: String = "",
    @SerialName("tv_archive_duration") val tvArchiveDuration: Int = 0,
    @SerialName("category_id") val categoryId: String = "",
    @SerialName("category_ids") val categoryIds: List<Int> = emptyList(),
    @SerialName("thumbnail") val thumbnail: String = ""
)

@Serializable
data class VodStream(
    @SerialName("num") val num: Int = 0,
    val name: String = "",
    @SerialName("stream_type") val streamType: String = "",
    @SerialName("stream_id") val streamId: Int = 0,
    @SerialName("stream_icon") val streamIcon: String = "",
    val rating: String = "",
    @SerialName("rating_5based") val rating5: Double = 0.0,
    val added: String? = null,
    @SerialName("category_id") val categoryId: String = "",
    @SerialName("category_ids") val categoryIds: List<Int> = emptyList(),
    @SerialName("container_extension") val containerExtension: String = "",
    @SerialName("custom_sid") val customSid: String? = null,
    @SerialName("direct_source") val directSource: String = "",
    val year: String = "",
    val genre: String = "",
    val plot: String = "",
    val cast: String = "",
    val director: String = "",
    @SerialName("release_date") val releaseDate: String = "",
    @SerialName("tmdb_id") val tmdbId: String = ""
)

@Serializable
data class SeriesStream(
    @SerialName("num") val num: Int = 0,
    val name: String = "",
    @SerialName("series_id") val seriesId: Int = 0,
    val cover: String = "",
    val plot: String = "",
    val cast: String = "",
    val director: String = "",
    val genre: String = "",
    @SerialName("release_date") val releaseDate: String = "",
    @SerialName("last_modified") val lastModified: String? = null,
    val rating: String = "",
    @SerialName("rating_5based") val rating5: Double = 0.0,
    @SerialName("backdrop_path") val backdropPath: List<String> = emptyList(),
    val year: String = "",
    @SerialName("episode_run_time") val episodeRunTime: String = "",
    @SerialName("category_id") val categoryId: String = "",
    @SerialName("category_ids") val categoryIds: List<Int> = emptyList(),
    val added: String? = null,
    @SerialName("tmdb_id") val tmdbId: String = ""
)

@Serializable
data class SeriesInfo(
    val seasons: Map<String, List<Episode>> = emptyMap(),
    val info: SeriesDetails? = null,
    val episodes: Map<String, List<Episode>> = emptyMap()
)

@Serializable
data class SeriesDetails(
    val name: String = "",
    val cover: String = "",
    val plot: String = "",
    val cast: String = "",
    val director: String = "",
    val genre: String = "",
    @SerialName("release_date") val releaseDate: String = "",
    val rating: String = "",
    @SerialName("backdrop_path") val backdropPath: List<String> = emptyList(),
    val year: String = "",
    @SerialName("episode_run_time") val episodeRunTime: String = ""
)

@Serializable
data class Episode(
    val id: String = "",
    @SerialName("episode_num") val episodeNum: Int = 0,
    val title: String = "",
    @SerialName("container_extension") val containerExtension: String = "",
    val info: EpisodeInfo? = null,
    @SerialName("custom_sid") val customSid: String? = null,
    val added: String? = null,
    val season: Int = 0,
    @SerialName("direct_source") val directSource: String = ""
)

@Serializable
data class EpisodeInfo(
    @SerialName("tmdb_id") val tmdbId: String? = null,
    val releasedate: String? = null,
    val plot: String? = null,
    val duration_secs: Int = 0,
    val duration: String = "",
    @SerialName("movie_image") val movieImage: String = "",
    val rating: Double = 0.0
)

@Serializable
data class EpgListing(
    @SerialName("epg_id") val epgId: String = "",
    val title: String = "",
    @SerialName("lang") val language: String = "",
    val start: String = "",
    val end: String = "",
    val description: String = "",
    @SerialName("channel_id") val channelId: String = "",
    @SerialName("start_timestamp") val startTimestamp: Long = 0,
    @SerialName("stop_timestamp") val stopTimestamp: Long = 0
)

data class ContentItem(
    val id: Int,
    val name: String,
    val coverUrl: String,
    val year: String = "",
    val rating: Double = 0.0,
    val genre: String = "",
    val plot: String = "",
    val addedTimestamp: Long = 0,
    val type: ContentType,
    val containerExtension: String = "",
    val releaseDate: String = "",
    val cast: String = "",
    val director: String = "",
    val backdropUrl: String = "",
    val categoryId: String = ""
)

enum class ContentType { MOVIE, SERIES, LIVE, SPORTS }

data class ComingSoonItem(
    val id: Int,
    val name: String,
    val coverUrl: String,
    val releaseDate: Long,
    val genre: String = "",
    val plot: String = "",
    val type: ContentType,
    val backdropUrl: String = ""
)

enum class SortOption(val label: String) {
    DEFAULT("Default"),
    NAME_ASC("A-Z"),
    NAME_DESC("Z-A"),
    YEAR_2026("2026"),
    YEAR_DESC("Year (Newest)"),
    YEAR_ASC("Year (Oldest)"),
    RATING_DESC("Rating (High)"),
    RATING_ASC("Rating (Low)"),
    RECENTLY_ADDED("Recently Added")
}

data class AppCredentials(
    val serverUrl: String = "",
    val username: String = "",
    val password: String = ""
) {
    val isValid get() = serverUrl.isNotBlank() && username.isNotBlank() && password.isNotBlank()
}
