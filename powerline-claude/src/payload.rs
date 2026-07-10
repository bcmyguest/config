//! Deserialization of the statusline JSON Claude Code writes to stdin.
//!
//! Every field is optional: the payload grows across Claude Code versions and
//! several objects (`effort`, `cost`, `context_window.current_usage`) are
//! documented as absent or null in normal operation.

use serde::Deserialize;

#[derive(Debug, Default, Deserialize)]
pub struct Payload {
    cwd: Option<String>,
    model: Option<Model>,
    workspace: Option<Workspace>,
    cost: Option<Cost>,
    context_window: Option<ContextWindow>,
    effort: Option<Effort>,
}

#[derive(Debug, Deserialize)]
struct Model {
    id: Option<String>,
    display_name: Option<String>,
}

#[derive(Debug, Deserialize)]
struct Workspace {
    current_dir: Option<String>,
    project_dir: Option<String>,
}

#[derive(Debug, Deserialize)]
struct Cost {
    total_cost_usd: Option<f64>,
    total_duration_ms: Option<u64>,
    total_lines_added: Option<u64>,
    total_lines_removed: Option<u64>,
}

#[derive(Debug, Deserialize)]
struct ContextWindow {
    total_input_tokens: Option<u64>,
    context_window_size: Option<u64>,
    current_usage: Option<CurrentUsage>,
}

#[derive(Debug, Deserialize)]
struct CurrentUsage {
    input_tokens: Option<u64>,
    cache_creation_input_tokens: Option<u64>,
    cache_read_input_tokens: Option<u64>,
}

#[derive(Debug, Deserialize)]
struct Effort {
    level: Option<String>,
}

impl Payload {
    pub fn from_json(json: &str) -> Result<Self, serde_json::Error> {
        serde_json::from_str(json)
    }

    pub fn model_display_name(&self) -> Option<&str> {
        let model = self.model.as_ref()?;
        model.display_name.as_deref().or(model.id.as_deref())
    }

    pub fn effort_level(&self) -> Option<&str> {
        self.effort.as_ref()?.level.as_deref()
    }

    /// Directory the bar should describe: workspace current dir, falling back
    /// to the project dir, then the raw cwd.
    pub fn dir(&self) -> Option<&str> {
        let from_workspace = self.workspace.as_ref().and_then(|workspace| {
            workspace
                .current_dir
                .as_deref()
                .or(workspace.project_dir.as_deref())
        });
        from_workspace.or(self.cwd.as_deref())
    }

    /// Tokens currently in the context window: the sum of the last API call's
    /// input and cache tokens, falling back to `total_input_tokens` (the same
    /// sum, pre-computed by Claude Code) when `current_usage` is null.
    pub fn current_tokens(&self) -> Option<u64> {
        let window = self.context_window.as_ref()?;
        match window.current_usage.as_ref() {
            Some(usage) => Some(
                usage.input_tokens.unwrap_or(0)
                    + usage.cache_creation_input_tokens.unwrap_or(0)
                    + usage.cache_read_input_tokens.unwrap_or(0),
            ),
            None => window.total_input_tokens,
        }
    }

    pub fn context_window_size(&self) -> Option<u64> {
        self.context_window.as_ref()?.context_window_size
    }

    pub fn total_cost_usd(&self) -> Option<f64> {
        self.cost.as_ref()?.total_cost_usd
    }

    pub fn total_duration_ms(&self) -> Option<u64> {
        self.cost.as_ref()?.total_duration_ms
    }

    pub fn lines_added(&self) -> Option<u64> {
        self.cost.as_ref()?.total_lines_added
    }

    pub fn lines_removed(&self) -> Option<u64> {
        self.cost.as_ref()?.total_lines_removed
    }
}
