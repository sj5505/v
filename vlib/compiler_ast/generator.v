module compiler

interface Generater {
	unary_expr(u UnaryExpr, c Context) string
	binary_expr(b BinaryExpr, c Context) string
	if_expr(i IfExpr, c Context) string
	if_optional_expr(i IfOptionalExpr, c Context) string
	for_bool_expr(f ForBoolExpr, c Context) string
	for_in_expr(f ForInExpr, c Context) string
	match_expr(m MatchExpr, c Context) string
	cast_expr(c CastExpr, ctx Context) string
	delegate_expr(d DelegateExpr, c Context) string
	or_expr(o OrExpr, c Context) string
	function_call_expr(f FunctionCallExpr, c Context) string
	property_expr(p PropertyExpr, c Context) string
	namespace_expr(n NamespaceExpr, c Context) string
	none_literal_expr(n NoneLiteralExpr, c Context) string
	array_literal_expr(a ArrayLiteralExpr, c Context) string
	bool_literal_expr(b BoolLiteralExpr, c Context) string
	int_literal_expr(i IntLiteralExpr, c Context) string
	float_literal_expr(f FloatLiteralExpr, c Context) string
	string_literal_expr(s StringLiteralExpr, c Context) string
	struct_expr(s StructExpr, c Context) string
	struct_modification_expr(s StructModificationExpr, c Context) string
	function_decl_expr(f FunctionDeclExpr, c Context) string
	variable_expr(v VariableExpr, c Context) string
	assert_stmt(a AssertStmt, c Context) string
	evaluate_stmt(e EvaluateStmt, c Context) string
	assign_stmt(a AssignStmt, c Context) string
	compile_time_if_stmt(c CompileTimeIfStmt, ctx Context) string
	append_stmt(a AppendStmt, c Context) string
	variable_decl_stmt(v VariableDeclStmt, c Context) string
	enum_decl_stmt(e EnumDeclStmt, c Context) string
	struct_decl_stmt(s StructDeclStmt, c Context) string
	interface_decl_stmt(i InterfaceDeclStmt, c Context) string
	comment_stmt(c CommentStmt, c Context) string
	break_stmt(b BreakStmt, c Context) string
	continue_stmt(c ContinueStmt, ctx Context) string
	return_stmt(r ReturnStmt, ctx Context) string
	import_stmt(i ImportStmt, c Context) string
}

struct Context {

}
