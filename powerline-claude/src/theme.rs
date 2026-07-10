//! Color themes, ported from the starship-claude palette files.
//!
//! A palette defines fg/bg pairs per semantic family (claude, directory, git,
//! model, context, cost). The two segments that have no upstream family
//! (stats, effort) reuse existing families so every theme stays coherent:
//! stats renders with the cost fg on the context bg, effort with the model
//! colors.

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Rgb {
    pub r: u8,
    pub g: u8,
    pub b: u8,
}

impl Rgb {
    pub const fn hex(value: u32) -> Self {
        Self {
            r: (value >> 16) as u8,
            g: (value >> 8) as u8,
            b: value as u8,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct SegmentColors {
    pub fg: Rgb,
    pub bg: Rgb,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SegmentKind {
    Logo,
    Dir,
    Git,
    Model,
    Context,
    Cost,
    Stats,
    Effort,
}

/// One vendored palette: the semantic fg/bg values from the upstream
/// `palettes/*.toml` files.
#[derive(Debug)]
struct Palette {
    name: &'static str,
    claude: (u32, u32),
    directory: (u32, u32),
    git: (u32, u32),
    model: (u32, u32),
    context: (u32, u32),
    cost: (u32, u32),
}

const PALETTES: &[Palette] = &[
    Palette {
        name: "catppuccin-mocha",
        claude: (0xd97757, 0x313244),
        directory: (0x89dceb, 0x1e1e2e),
        git: (0xeba0ac, 0x313244),
        model: (0xb4befe, 0x1e1e2e),
        context: (0xfab387, 0x313244),
        cost: (0xa6e3a1, 0x45475a),
    },
    Palette {
        name: "catppuccin-frappe",
        claude: (0xd97757, 0xeff1f5),
        directory: (0x04a5e5, 0xeff1f5),
        git: (0xdd7878, 0xccd0da),
        model: (0x8839ef, 0xeff1f5),
        context: (0xdf8e1d, 0xccd0da),
        cost: (0x40a02b, 0xbcc0cc),
    },
    Palette {
        name: "dracula",
        claude: (0xd97757, 0x44475a),
        directory: (0x8be9fd, 0x282a36),
        git: (0xbd93f9, 0x44475a),
        model: (0x8be9fd, 0x282a36),
        context: (0xffb86c, 0x44475a),
        cost: (0x50fa7b, 0x4d4f68),
    },
    Palette {
        name: "gruvbox-dark",
        claude: (0xd97757, 0x282828),
        directory: (0x83a598, 0x282828),
        git: (0xb16286, 0x3c3836),
        model: (0x458588, 0x282828),
        context: (0xd79921, 0x3c3836),
        cost: (0x689d6a, 0x504945),
    },
    Palette {
        name: "nord",
        claude: (0xd97757, 0x2e3440),
        directory: (0x88c0d0, 0x2e3440),
        git: (0xb48ead, 0x3b4252),
        model: (0x5e81ac, 0x2e3440),
        context: (0x8fbcbb, 0x3b4252),
        cost: (0xa3be8c, 0x434c5e),
    },
    Palette {
        name: "tokyonight",
        claude: (0x090c0c, 0xa3aed2),
        directory: (0xe3e5e5, 0x769ff0),
        git: (0x769ff0, 0x394260),
        model: (0x769ff0, 0x212736),
        context: (0xa0a9cb, 0x1d2230),
        cost: (0xc0caf5, 0x414868),
    },
];

#[derive(Debug)]
pub struct Theme {
    palette: &'static Palette,
}

impl Default for Theme {
    fn default() -> Self {
        Self {
            palette: &PALETTES[0],
        }
    }
}

impl Theme {
    pub fn by_name(name: &str) -> Result<Self, String> {
        PALETTES
            .iter()
            .find(|palette| palette.name == name)
            .map(|palette| Self { palette })
            .ok_or_else(|| {
                let available: Vec<&str> = PALETTES.iter().map(|p| p.name).collect();
                format!(
                    "unknown theme '{name}', available: {}",
                    available.join(", ")
                )
            })
    }

    pub fn name(&self) -> &'static str {
        self.palette.name
    }

    pub fn colors(&self, kind: SegmentKind) -> SegmentColors {
        let (fg, bg) = match kind {
            SegmentKind::Logo => self.palette.claude,
            SegmentKind::Dir => self.palette.directory,
            SegmentKind::Git => self.palette.git,
            SegmentKind::Model => self.palette.model,
            SegmentKind::Context => self.palette.context,
            SegmentKind::Cost => self.palette.cost,
            SegmentKind::Stats => (self.palette.cost.0, self.palette.context.1),
            SegmentKind::Effort => self.palette.model,
        };
        SegmentColors {
            fg: Rgb::hex(fg),
            bg: Rgb::hex(bg),
        }
    }
}
