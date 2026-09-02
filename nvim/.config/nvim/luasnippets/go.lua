local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local sn = ls.snippet_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep

return {
  -- Error check; cycle the return form with a choice keymap
  s(
    { trig = 'er', desc = 'if err != nil' },
    fmt(
      [[
if err != nil {{
	{}
}}
]],
      {
        c(1, {
          t 'return err',
          sn(nil, fmt('return fmt.Errorf("{}: %w", err)', { i(1) })),
          t 't.Fatal(err)',
        }),
      }
    )
  ),

  -- Basic test function
  s(
    { trig = 'tst', desc = 'Test function' },
    fmt(
      [[
func Test{}(t *testing.T) {{
	{}
}}
]],
      { i(1, 'Name'), i(0) }
    )
  ),

  -- Table-driven test with subtests
  s(
    { trig = 'ttst', desc = 'Table-driven test' },
    fmt(
      [[
func Test{}(t *testing.T) {{
	tests := []struct {{
		name string
		{}
	}}{{
		{{name: "{}"}},
	}}
	for _, tt := range tests {{
		t.Run(tt.name, func(t *testing.T) {{
			{}
		}})
	}}
}}
]],
      { i(1, 'Name'), i(2, 'input string'), i(3, 'case'), i(0) }
    )
  ),

  -- got/want assertion
  s(
    { trig = 'gw', desc = 'Assert got != want' },
    fmt(
      [[
if {} != {} {{
	t.Errorf("got=%v but want=%v", {}, {})
}}
]],
      { i(1, 'got'), i(2, 'want'), rep(1), rep(2) }
    )
  ),

  -- got/want assertion for slices, maps and structs
  s(
    { trig = 'gwd', desc = 'Assert got deep-equals want' },
    fmt(
      [[
if !reflect.DeepEqual({}, {}) {{
	t.Errorf("got=%v but want=%v", {}, {})
}}
]],
      { i(1, 'got'), i(2, 'want'), rep(1), rep(2) }
    )
  ),

  -- Assert a specific error
  s(
    { trig = 'gwe', desc = 'Assert errors.Is' },
    fmt(
      [[
if !errors.Is({}, {}) {{
	t.Errorf("got err=%v but want err=%v", {}, {})
}}
]],
      { i(1, 'err'), i(2, 'want'), rep(1), rep(2) }
    )
  ),

  -- Fail on unexpected error
  s(
    { trig = 'noerr', desc = 'Fatal on unexpected error' },
    fmt(
      [[
if err != nil {{
	t.Fatalf("unexpected error: %v", err)
}}
]],
      {}
    )
  ),

  -- Test helper
  s(
    { trig = 'th', desc = 'Test helper function' },
    fmt(
      [[
func {}(t *testing.T{}) {{
	t.Helper()
	{}
}}
]],
      { i(1, 'assertName'), i(2), i(0) }
    )
  ),

  -- Fuzz test
  s(
    { trig = 'fz', desc = 'Fuzz test' },
    fmt(
      [[
func Fuzz{}(f *testing.F) {{
	f.Add({})
	f.Fuzz(func(t *testing.T, {}) {{
		{}
	}})
}}
]],
      { i(1, 'Name'), i(2, '"seed"'), i(3, 'input string'), i(0) }
    )
  ),

  -- Benchmark (Go 1.24+)
  s(
    { trig = 'bl', desc = 'Benchmark with b.Loop' },
    fmt(
      [[
func Benchmark{}(b *testing.B) {{
	for b.Loop() {{
		{}
	}}
}}
]],
      { i(1, 'Name'), i(0) }
    )
  ),

  -- Parallel test; cycle to a parallel subtest
  s(
    { trig = 'tp', desc = 't.Parallel' },
    c(1, {
      t 't.Parallel()',
      sn(
        nil,
        fmt(
          [[
t.Run({}, func(t *testing.T) {{
	t.Parallel()
	{}
}})
]],
          { i(1, 'tt.name'), i(2) }
        )
      ),
    })
  ),

  -- Context with timeout
  s(
    { trig = 'ctx', desc = 'context.WithTimeout' },
    fmt(
      [[
ctx, cancel := context.WithTimeout({}, {})
defer cancel()
]],
      { i(1, 'context.Background()'), i(2, 'time.Second') }
    )
  ),

  -- Open file with error check and deferred close; cycle Open/Create
  s(
    { trig = 'fo', desc = 'Open file with defer close' },
    fmt(
      [[
{}, err := os.{}({})
if err != nil {{
	return err
}}
defer {}.Close()
]],
      { i(1, 'f'), c(2, { t 'Open', t 'Create' }), i(3, 'path'), rep(1) }
    )
  ),

  -- Wrap error
  s({ trig = 'errw', desc = 'Wrap error' }, fmt('fmt.Errorf("{}: %w", err)', { i(1) })),

  -- Structured log
  s({ trig = 'sl', desc = 'slog.Info' }, fmt('slog.{}("{}", "{}", {})', { c(1, { t 'Info', t 'Debug', t 'Warn', t 'Error' }), i(2, 'msg'), i(3, 'key'), i(4, 'val') })),
}
