"""Unicode normalization utilities."""

import unicodedata


def normalize_nfc(text: str) -> str:
    """Normalize text to NFC form for search/comparison.

    Args:
        text: Input text string

    Returns:
        NFC-normalized text
    """
    if not text:
        return text
    return unicodedata.normalize("NFC", text)


def is_valid_utf8(text: str) -> bool:
    """Check if text is valid UTF-8.

    Args:
        text: Input text string

    Returns:
        True if valid UTF-8, False otherwise
    """
    try:
        text.encode("utf-8").decode("utf-8")
        return True
    except UnicodeError:
        return False