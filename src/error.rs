use std::fmt;
use std::io;

#[derive(Debug)]
pub enum MdlError {
    Io(io::Error),
    Parse(String),
    TextureDecode(String),
    Network(String),
    NotFound(String),
    InvalidFormat(String),
}

impl fmt::Display for MdlError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            MdlError::Io(err) => write!(f, "IO error: {}", err),
            MdlError::Parse(msg) => write!(f, "Parse error: {}", msg),
            MdlError::TextureDecode(msg) => write!(f, "Texture decode error: {}", msg),
            MdlError::Network(msg) => write!(f, "Network error: {}", msg),
            MdlError::NotFound(msg) => write!(f, "Not found: {}", msg),
            MdlError::InvalidFormat(msg) => write!(f, "Invalid format: {}", msg),
        }
    }
}

impl std::error::Error for MdlError {}

impl From<io::Error> for MdlError {
    fn from(err: io::Error) -> Self {
        MdlError::Io(err)
    }
}

impl From<reqwest::Error> for MdlError {
    fn from(err: reqwest::Error) -> Self {
        MdlError::Network(err.to_string())
    }
}

impl From<blp::error::error::BlpError> for MdlError {
    fn from(err: blp::error::error::BlpError) -> Self {
        MdlError::TextureDecode(format!("BLP error: {:?}", err))
    }
}

// Для совместимости с Box<dyn Error>
impl From<Box<dyn std::error::Error + Send + Sync>> for MdlError {
    fn from(err: Box<dyn std::error::Error + Send + Sync>) -> Self {
        MdlError::Parse(err.to_string())
    }
}

impl From<String> for MdlError {
    fn from(s: String) -> Self {
        MdlError::Parse(s)
    }
}

impl From<&str> for MdlError {
    fn from(s: &str) -> Self {
        MdlError::Parse(s.to_string())
    }
}
