@tool
class_name YAMLSyntaxHighlighter extends EditorSyntaxHighlighter

# Theme settings and cache
var theme_overrides: Dictionary
var cache: Dictionary = {}

# Token types for clearer code organization
enum TokenType {
	TEXT,      # For keys only
	COMMENT,   # Comments
	SYMBOL,    # Structural elements like :, -, >, |, &, *, [, ], {, }
	STRING,    # String values (default for unmatched values)
	NUMBER,    # Numeric values
	KEYWORD,   # Booleans, null, merge keys, tags
}

# Regular expressions for top-level patterns
var re_patterns := {
	"comment": RegEx.create_from_string("^\\s*#.*$"),
	"merge_key": RegEx.create_from_string("^\\s*<<:\\s*\\*[^\\s]+"),
	"multiline_indicator": RegEx.create_from_string("(>|\\|-?)\\s*$"),
	"array_item": RegEx.create_from_string("^\\s*-(\\s-|\\s+)+(.*)$"),
	"key_value": RegEx.create_from_string("^\\s*([^:]+):(.*)$"),

	# Scalar patterns
	"quoted_string": RegEx.create_from_string("^(['\"])(?:\\\\.|[^\\\\])*\\1$"),
	"number": RegEx.create_from_string("^(?:0[xX][0-9a-fA-F]+|0[oO][0-7]+|0[bB][0-1]+|[-+]?(?:\\d+\\.?\\d*|\\.\\d+)(?:[eE][-+]?\\d+)?)$"),
	"boolean": RegEx.create_from_string("^(true|false)$"),
	"nullish": RegEx.create_from_string("^(null|~)$"),
	"special": RegEx.create_from_string("^(\\.inf|\\.nan)$"),
	"anchor": RegEx.create_from_string("^\\s*&([^\\s]+)"),
	"alias": RegEx.create_from_string("^\\s*\\*([^\\s]+)"),
	"tag": RegEx.create_from_string("!!?[a-zA-Z0-9][a-zA-Z0-9_-]*"),
}

class ParserState:
	var in_string: bool = false
	var string_char: String = ""
	var stack: Array = []  # For nested flow collections
	var token_start: int = -1
	var colors: Dictionary = {}

	func push(char: String) -> void:
		stack.push_back(char)

	func pop() -> String:
		return stack.pop_back() if not stack.is_empty() else ""

	func peek() -> String:
		return stack.back() if not stack.is_empty() else ""

func clear_highlighting_cache() -> void:
	cache.clear()

func _update_theme_overrides() -> void:
	var settings = EditorInterface.get_editor_settings()
	theme_overrides = {
		"text_color": settings.get_setting("text_editor/theme/highlighting/text_color"),
		"comment_color": settings.get_setting("text_editor/theme/highlighting/comment_color"),
		"symbol_color": settings.get_setting("text_editor/theme/highlighting/symbol_color"),
		"string_color": settings.get_setting("text_editor/theme/highlighting/string_color"),
		"number_color": settings.get_setting("text_editor/theme/highlighting/number_color"),
		"keyword_color": settings.get_setting("text_editor/theme/highlighting/keyword_color"),
	}

func _get_color_for_type(type: TokenType) -> Color:
	match type:
		TokenType.TEXT: return theme_overrides.text_color
		TokenType.COMMENT: return theme_overrides.comment_color
		TokenType.SYMBOL: return theme_overrides.symbol_color
		TokenType.STRING: return theme_overrides.string_color
		TokenType.NUMBER: return theme_overrides.number_color
		TokenType.KEYWORD: return theme_overrides.keyword_color
		_: return theme_overrides.string_color  # Default fallback is string color

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var text: String = get_text_edit().get_line(line)
	_update_theme_overrides()

	# Use cache if available
	if text in cache:
		return cache[text]

	var colors := _highlight_line(text)
	cache[text] = _sort_colors(colors)
	return cache[text]

func _highlight_line(text: String) -> Dictionary:
	# Handle comments first
	if re_patterns.comment.search(text):
		return {0: {"color": _get_color_for_type(TokenType.COMMENT)}}

	# Handle merge keys
	var merge_match = re_patterns.merge_key.search(text)
	if merge_match:
		return {
			merge_match.get_start(0): {"color": _get_color_for_type(TokenType.KEYWORD)}
		}

	# Handle regular key-value pairs first
	var key_value_match = re_patterns.key_value.search(text)
	if key_value_match:
		return _parse_key_value(text, key_value_match)

	# Handle array items
	var array_match = re_patterns.array_item.search(text)
	if array_match:
		var colors := {}
		_add_color(colors, array_match.get_start(1), array_match.get_end(1), TokenType.SYMBOL)
		var content: String = array_match.get_string(2).strip_edges()
		if content:
			var content_start := text.find(content, array_match.get_end(1))
			if content_start != -1:
				if content.begins_with("[") or content.begins_with("{"):
					colors.merge(_parse_flow_style(content, content_start))
				else:
					_add_scalar_color(colors, content, content_start)
		return colors

	# Handle flow-style collections at the root level
	if "[" in text or "{" in text:
		return _parse_flow_style(text, 0)

	# Handle multi-line string indicators
	var multiline_match = re_patterns.multiline_indicator.search(text)
	if multiline_match:
		var colors := {}
		# Color the indicator (> or |) as symbol
		_add_color(colors, multiline_match.get_start(1), multiline_match.get_end(1), TokenType.SYMBOL)
		return colors

	# Default case: treat as string content (for multi-line string content)
	if text.strip_edges():
		return {0: {"color": _get_color_for_type(TokenType.STRING)}}

	return {}

func _parse_flow_style(text: String, offset: int) -> Dictionary:
	var state := ParserState.new()
	var pos := 0

	while pos < text.length():
		var char := text[pos]

		# Handle string literals
		if char in ['"', "'"] and (pos == 0 or text[pos - 1] != '\\'):
			if not state.in_string:
				state.in_string = true
				state.string_char = char
				state.token_start = pos
			elif char == state.string_char:
				state.in_string = false
				_add_color(state.colors, offset + state.token_start, offset + pos + 1, TokenType.STRING)
				state.token_start = -1

		# Handle flow collection brackets when not in string
		elif not state.in_string:
			if char in ['[', '{']:
				state.push(char)
				_add_color(state.colors, offset + pos, offset + pos + 1, TokenType.SYMBOL)
				state.token_start = pos + 1

			elif char in [']', '}']:
				var matching := '[' if char == ']' else '{'
				if state.peek() == matching:
					state.pop()
					if state.token_start != -1:
						var token := text.substr(state.token_start, pos - state.token_start).strip_edges()
						if token:
							_add_scalar_color(state.colors, token, offset + state.token_start)
					_add_color(state.colors, offset + pos, offset + pos + 1, TokenType.SYMBOL)
					state.token_start = -1

			elif char in [':', ',']:
				if state.token_start != -1:
					var token := text.substr(state.token_start, pos - state.token_start).strip_edges()
					if token:
						if char == ':':
							# All map keys should be text colored, regardless of content
							_add_color(state.colors, offset + state.token_start, offset + pos, TokenType.TEXT)
						else:
							_add_scalar_color(state.colors, token, offset + state.token_start)
				_add_color(state.colors, offset + pos, offset + pos + 1, TokenType.SYMBOL)
				state.token_start = pos + 1

			elif char != ' ' and state.token_start == -1:
				state.token_start = pos

		pos += 1

	# Handle any remaining token
	if state.token_start != -1 and state.token_start < pos:
		var token := text.substr(state.token_start, pos - state.token_start).strip_edges()
		if token:
			# Check if this is a key in a map context
			if not state.stack.is_empty() and state.stack.back() == '{' and ':' in text.substr(pos):
				_add_color(state.colors, offset + state.token_start, offset + pos, TokenType.TEXT)
			else:
				_add_scalar_color(state.colors, token, offset + state.token_start)

	return state.colors

func _parse_key_value(text: String, match: RegExMatch) -> Dictionary:
	var colors := {}

	# Color the key
	_add_color(colors, match.get_start(1), match.get_end(1), TokenType.TEXT)

	# Color the colon
	_add_color(colors, match.get_end(1), match.get_end(1) + 1, TokenType.SYMBOL)

	# Get and process the value if present
	var value := match.get_string(2).strip_edges()
	if value:
		var value_start := text.find(value, match.get_end(1))
		if value_start != -1:
			# First check for and handle any tags
			var tag_match = re_patterns.tag.search(value)
			if tag_match:
				_add_color(colors, value_start + tag_match.get_start(0),
						  value_start + tag_match.get_end(0), TokenType.KEYWORD)
				# Get remaining content after tag
				var after_tag = value.substr(tag_match.get_end(0)).strip_edges()
				if after_tag:
					var after_tag_start = text.find(after_tag, value_start + tag_match.get_end(0))
					# Now check for multiline indicator in remaining content
					var indicator_match = re_patterns.multiline_indicator.search(after_tag)
					if indicator_match:
						_add_color(colors, after_tag_start + indicator_match.get_start(1),
								 after_tag_start + indicator_match.get_end(1), TokenType.SYMBOL)
					return colors

			# If no tag, check for multiline indicator in full value
			var indicator_match = re_patterns.multiline_indicator.search(value)
			if indicator_match:
				_add_color(colors, value_start + indicator_match.get_start(1),
						  value_start + indicator_match.get_end(1), TokenType.SYMBOL)
			elif value.begins_with("[") or value.begins_with("{"):
				colors.merge(_parse_flow_style(value, value_start))
			else:
				_add_scalar_color(colors, value, value_start)
	return colors

func _add_scalar_color(colors: Dictionary, token: String, start_index: int) -> void:
	# Handle empty or whitespace-only tokens
	token = token.strip_edges()
	if token.is_empty():
		return

	# Check for quoted strings first
	if re_patterns.quoted_string.search(token):
		_add_color(colors, start_index, start_index + token.length(), TokenType.STRING)
		return  # Important: return early to prevent parsing tags inside strings

	# Now check for tags since we know we're not in a string
	elif re_patterns.tag.search(token):
		var tag_match = re_patterns.tag.search(token)
		# Only color the tag portion, not the following content
		var tag_length = tag_match.get_end(0)
		_add_color(colors, start_index, start_index + tag_length, TokenType.KEYWORD)
		# Process any remaining content after the tag
		if tag_length < token.length():
			var remaining = token.substr(tag_length).strip_edges()
			if remaining:
				_add_scalar_color(colors, remaining, start_index + tag_length)
	# Rest of the scalar checks...
	elif re_patterns.number.search(token):
		_add_color(colors, start_index, start_index + token.length(), TokenType.NUMBER)
	elif re_patterns.boolean.search(token) or re_patterns.nullish.search(token) or re_patterns.special.search(token):
		_add_color(colors, start_index, start_index + token.length(), TokenType.KEYWORD)
	elif re_patterns.anchor.search(token) or re_patterns.alias.search(token):
		_add_color(colors, start_index, start_index + token.length(), TokenType.SYMBOL)
	else:
		# Default fallback is string color
		_add_color(colors, start_index, start_index + token.length(), TokenType.STRING)

func _add_color(colors: Dictionary, start: int, end: int, type: TokenType) -> void:
	colors[start] = {"color": _get_color_for_type(type)}

func _sort_colors(colors: Dictionary) -> Dictionary:
	# Get all indices as an array
	var indices = colors.keys()
	indices.sort()  # Sort indices in ascending order

	# Create new dictionary with sorted indices
	var sorted_colors := {}
	for idx in indices:
		sorted_colors[idx] = colors[idx]

	return sorted_colors
