//! REST API of the node

pub mod v0_node_stats;

mod server_service;

pub use self::server_service::{Error, ServerService};

use self::v0_node_stats::StatsCounter;
use settings::start::{Error as ConfigError, Rest};
use settings::Error as SettingsError;

pub fn start_rest_server(
    config: &Rest,
    stats_counter: StatsCounter,
) -> Result<ServerService, SettingsError> {
    let prefix = config
        .prefix
        .as_ref()
        .map(|prefix| prefix.as_str())
        .unwrap_or("/");
    ServerService::builder(&config.pkcs12, config.listen.clone(), prefix)
        .add_handler(v0_node_stats::crate_handler(stats_counter))
        .build()
        .map_err(|e| SettingsError::Start(ConfigError::InvalidRest(e)))
}