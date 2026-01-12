"""yt-dlp service wrapper"""

import yt_dlp
from typing import Dict, List, Any
from app.core.logger import logger
from app.core.exceptions import (
    UnsupportedURLException,
    PrivateContentException,
    ExtractionException,
    NetworkException,
)
from app.config import settings


class YTDLPService:
    """Service for interacting with yt-dlp"""

    def __init__(self):
        """Initialize yt-dlp options"""
        self.base_options = {
            "quiet": not settings.DEBUG,
            "no_warnings": not settings.DEBUG,
            "socket_timeout": settings.TIMEOUT,
            "no_check_certificate": False,
            "prefer_insecure": False,
            # Better headers to avoid bot detection
            "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "referer": "https://www.youtube.com/",
            # Force best quality with audio merged
            # This ensures video+audio are merged if separate streams
            "format": "bestvideo+bestaudio/best",
            # Merge output format
            "merge_output_format": "mp4",
            # YouTube specific options
            "extractor_args": {
                "youtube": {
                    "player_client": ["android", "web"],
                    "player_skip": ["configs"],
                }
            },
        }

    def _get_browser_cookies(self):
        """Try to get cookies from available browsers"""
        browsers = ["chrome", "firefox", "edge"]

        for browser in browsers:
            try:
                # Test if browser cookies are accessible
                test_options = {
                    "quiet": True,
                    "no_warnings": True,
                    "cookiesfrombrowser": (browser,),
                }
                with yt_dlp.YoutubeDL(test_options) as ydl:  # type: ignore
                    # If no error, browser cookies are accessible
                    logger.info(f"Using cookies from {browser}")
                    return (browser,)
            except Exception:
                continue

        logger.warning("No browser cookies available for retry")
        return None

    def extract_info(self, url: str, download: bool = False) -> Dict[str, Any]:
        """
        Extract information from URL using yt-dlp

        Args:
            url: The URL to extract information from
            download: Whether to download the file

        Returns:
            Dictionary containing extracted information

        Raises:
            UnsupportedURLException: If URL is not supported
            PrivateContentException: If content is private/restricted
            ExtractionException: If extraction fails
            NetworkException: If network error occurs
        """
        options = {
            **self.base_options,
            "skip_download": not download,
        }

        try:
            with yt_dlp.YoutubeDL(options) as ydl:  # type: ignore
                logger.info(f"Extracting info from: {url}")
                info = ydl.extract_info(url, download=download)
                return info  # type: ignore

        except yt_dlp.utils.UnsupportedError as e:  # type: ignore
            logger.error(f"Unsupported URL: {url}")
            raise UnsupportedURLException(str(e))

        except yt_dlp.utils.DownloadError as e:  # type: ignore
            error_msg = str(e).lower()

            if "private" in error_msg or "not available" in error_msg:
                logger.error(f"Private/unavailable content: {url}")
                raise PrivateContentException("Content is private or not available")
            elif "geo" in error_msg or "restricted" in error_msg:
                logger.error(f"Geo-restricted content: {url}")
                raise PrivateContentException("Content is geographically restricted")
            elif "sign in" in error_msg or "bot" in error_msg or "cookies" in error_msg:
                # YouTube bot detection - try again with browser cookies
                logger.warning(
                    f"YouTube bot detection, retrying with browser cookies: {url}"
                )
                browser_cookies = self._get_browser_cookies()

                if browser_cookies:
                    try:
                        options_with_cookies = {
                            **self.base_options,
                            "skip_download": not download,
                            "cookiesfrombrowser": browser_cookies,
                        }
                        with yt_dlp.YoutubeDL(options_with_cookies) as ydl:  # type: ignore
                            logger.info(f"Retrying with browser cookies: {url}")
                            info = ydl.extract_info(url, download=download)
                            return info  # type: ignore
                    except Exception as retry_error:
                        logger.error(f"Retry with cookies failed: {retry_error}")
                        raise ExtractionException(
                            "YouTube requires authentication. Please make sure you are signed into YouTube in your Chrome, Firefox, or Edge browser, then restart the backend server."
                        )
                else:
                    raise ExtractionException(
                        "YouTube requires authentication. Please make sure you are signed into YouTube in your Chrome, Firefox, or Edge browser, then restart the backend server."
                    )
            else:
                logger.error(f"Download error: {e}")
                raise ExtractionException(str(e))

        except Exception as e:
            error_msg = str(e).lower()

            if (
                "network" in error_msg
                or "connection" in error_msg
                or "timeout" in error_msg
            ):
                logger.error(f"Network error: {e}")
                raise NetworkException(str(e))
            else:
                logger.error(f"Unexpected error: {e}")
                raise ExtractionException(f"Failed to extract information: {str(e)}")

    def get_metadata(self, url: str) -> Dict[str, Any]:
        """
        Get basic metadata from URL without downloading

        Args:
            url: The URL to get metadata from

        Returns:
            Dictionary with platform, title, and thumbnail_url
        """
        info = self.extract_info(url, download=False)

        # Extract platform name
        platform = info.get("extractor_key", "unknown").lower()
        if "youtube" in platform:
            platform = "youtube"
        elif "instagram" in platform:
            platform = "instagram"
        elif "twitter" in platform or "x.com" in platform:
            platform = "twitter"
        elif "facebook" in platform:
            platform = "facebook"
        elif "tiktok" in platform:
            platform = "tiktok"

        return {
            "platform": platform,
            "title": info.get("title", "Unknown Title"),
            "thumbnail_url": info.get("thumbnail", None),
        }

    def get_download_options(self, url: str) -> List[Dict[str, Any]]:
        """
        Get available download options for URL, categorized and limited
        Prioritizes merged video+audio formats for best user experience
        """
        info = self.extract_info(url, download=False)
        formats = info.get("formats", [])

        if not formats:
            raise ExtractionException("No formats available for this URL")

        video_audio = []
        audio_only = []
        video_only = []
        seen_combos = set()

        # Track best video and audio for creating merged options
        best_video_by_height = {}  # height -> format
        best_audio = None

        for fmt in formats:
            if not fmt.get("url"):
                continue

            ext = fmt.get("ext", "mp4")
            height = fmt.get("height")
            vcodec = fmt.get("vcodec", "none")
            acodec = fmt.get("acodec", "none")
            filesize = fmt.get("filesize") or fmt.get("filesize_approx")
            format_id = fmt.get("format_id", "")

            # Helper to create option dict
            def create_option(label, type_name, fmt_id=format_id, size=filesize):
                combo = (label, ext, type_name)
                if combo in seen_combos:
                    return None
                seen_combos.add(combo)
                return {
                    "quality_label": label,
                    "extension": ext,
                    "file_size_approx": size,
                    "download_url": fmt["url"],
                    "type": type_name,
                    "format_id": fmt_id,
                }

            # Track best audio for merging
            if acodec != "none" and (
                best_audio is None
                or (fmt.get("abr", 0) or 0) > (best_audio.get("abr", 0) or 0)
            ):
                best_audio = fmt

            # Track best video by resolution for merging
            if height and vcodec != "none":
                if height not in best_video_by_height:
                    best_video_by_height[height] = fmt

            # 1. Video + Audio (Pre-merged formats)
            if height and vcodec != "none" and acodec != "none":
                label = f"{height}p"
                opt = create_option(label, "video_audio")
                if opt:
                    video_audio.append(opt)

            # 2. Audio Only
            elif acodec != "none" and vcodec == "none":
                label = "Audio Only"
                if ext not in ["mp3", "m4a", "webm", "opus"]:
                    continue
                opt = create_option(label, "audio")
                if opt:
                    audio_only.append(opt)

            # 3. Video Only (for reference, but we'll create merged options)
            elif height and vcodec != "none" and acodec == "none":
                if height not in best_video_by_height:
                    best_video_by_height[height] = fmt

        # If no pre-merged formats found, create virtual merged options
        # This happens with Instagram, Twitter, etc.
        if not video_audio and best_audio and best_video_by_height:
            logger.info(
                f"No pre-merged formats found. Creating virtual merged options using format selector."
            )
            for height, vid_fmt in best_video_by_height.items():
                # Create a virtual merged option that yt-dlp will merge on download
                vid_id = vid_fmt.get("format_id", "")
                aud_id = best_audio.get("format_id", "")

                # Estimate combined size
                vid_size = (
                    vid_fmt.get("filesize") or vid_fmt.get("filesize_approx") or 0
                )
                aud_size = (
                    best_audio.get("filesize") or best_audio.get("filesize_approx") or 0
                )
                combined_size = vid_size + aud_size if vid_size and aud_size else None

                label = f"{height}p"
                combo = (label, "mp4", "video_audio")
                if combo not in seen_combos:
                    seen_combos.add(combo)
                    video_audio.append(
                        {
                            "quality_label": label,
                            "extension": "mp4",
                            "file_size_approx": combined_size,
                            "download_url": f"MERGE:{vid_id}+{aud_id}",  # Special marker for backend
                            "type": "video_audio",
                            "format_id": f"{vid_id}+{aud_id}",
                        }
                    )

        # Add video-only options (with clear warning)
        for height, vid_fmt in best_video_by_height.items():
            label = f"{height}p (Video Only - No Audio)"
            ext = vid_fmt.get("ext", "mp4")
            combo = (label, ext, "video_only")
            if combo not in seen_combos:
                seen_combos.add(combo)
                video_only.append(
                    {
                        "quality_label": label,
                        "extension": ext,
                        "file_size_approx": vid_fmt.get("filesize")
                        or vid_fmt.get("filesize_approx"),
                        "download_url": vid_fmt["url"],
                        "type": "video_only",
                        "format_id": vid_fmt.get("format_id", ""),
                    }
                )

        # Sort by resolution
        def resolution_key(o):
            try:
                return int(o["quality_label"].split("p")[0])
            except:
                return 0

        video_audio.sort(key=resolution_key, reverse=True)
        video_only.sort(key=resolution_key, reverse=True)
        audio_only.sort(key=lambda x: x["file_size_approx"] or 0, reverse=True)

        # Prioritize video+audio formats
        final_options = []
        final_options.extend(video_audio[:8])  # Merged formats first
        final_options.extend(audio_only[:3])
        final_options.extend(video_only[:3])  # Video-only last

        # Fallback if still empty
        if not final_options and formats:
            best = formats[-1]
            final_options.append(
                {
                    "quality_label": "Best Available",
                    "extension": best.get("ext", "mp4"),
                    "file_size_approx": best.get("filesize"),
                    "download_url": best.get("url"),
                    "type": "video_audio",
                    "format_id": best.get("format_id", ""),
                }
            )

        return final_options


# Global instance
ytdlp_service = YTDLPService()
