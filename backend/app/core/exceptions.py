"""Custom exceptions for URLens API"""


class URLensException(Exception):
    """Base exception for URLens"""
    pass


class UnsupportedURLException(URLensException):
    """Raised when URL is not supported"""
    pass


class PrivateContentException(URLensException):
    """Raised when content is private or restricted"""
    pass


class ExtractionException(URLensException):
    """Raised when media extraction fails"""
    pass


class NetworkException(URLensException):
    """Raised when network error occurs"""
    pass
