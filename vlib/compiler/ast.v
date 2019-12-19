module compiler

interface Noder {}

interface Stmter {
	generate(g Generater, c Context) string
	convert_to_expression() ?Exprer
}

interface Exprer {
	generate(g Generater, c Context) string
	resolve_type(c Context) Typer
}

enum UnaryOperand {
	not
	unary_add
	unary_sub
}

struct UnaryExpr {
	operand_type UnaryOperand
	target       Exprer
}

enum BinaryOperand {
	sum
	difference
	product
	quotient
	remainder
	bitwise_and
	bitwise_or
	bitwise_xor
	left_shift
	right_shift

	equality
	inequality
	less_than
	less_than_or_equal
	more_than
	more_than_or_equal

	in_check

	//These are suffixed with `bool` to prevent conflict with the keyword `or`
	and_bool
	or_bool
}

struct BinaryExpr {
	operand_type BinaryOperand
	left         Exprer
	right        Exprer
}

struct IfExpr {
	condition  Exprer
	if_block   []Stmter
	else_block []Stmter
}

struct IfOptionalExpr {
	condition            Exprer
	unwrapped_identifier string
	if_block             []Stmter
}

struct ForBoolExpr {
	initial_action Stmter
	condition     Exprer
	body          []Stmter
}

struct ForInExpr {
	array_to_loop_through Exprer
	index_identifier      string
	value_identifier      string
	body                  []Stmter
}

struct MatchExpr {
	to_match  Exprer
	cases     []MatchCase
	else_case []Stmter
}

struct MatchCase {
	condition []Exprer
	block     []Stmter
}

struct CastExpr {
	source Exprer
	target Typer
}

struct DelegateExpr {
	optional Exprer
}

struct OrExpr {
	optional Exprer
	or_block []Stmter
}

struct FunctionCallExpr {
	function_to_call Exprer
	parameters       []Exprer
}

struct PropertyExpr {
	object_to_access Exprer
	property_name    string
}

struct NamespaceExpr {
	namespace_name string
}

struct NoneLiteralExpr {}

struct ArrayLiteralExpr {
	content []Exprer
}

struct BoolLiteralExpr {
	literal bool
}

struct IntLiteralExpr {
	int_type IntType
	//TODO Upgrade to i128 when it's done
	literal  i64
}

struct FloatLiteralExpr {
	float_type FloatType
	literal f64
}

struct StringLiteralExpr {
	literal string
}

struct StructExpr {
	struct_to_init Typer
	parameters     map[string]Exprer
}

struct StructModificationExpr {
	original   Exprer
	parameters map[string]Exprer
}

enum InteropType {
	c
	v
}

struct FunctionDeclExpr {
	is_public                bool
	interop_type             InteropType
	func_name                string
	receiver_name            string
	receiver_type            Typer
	receiver_force_reference bool
	parameter                map[string]Typer
	return_type              Typer
	tags                     []string
	body                     []Stmter
}

struct VariableExpr {
	identifier string
}

struct AssertStmt {
	boolean_to_assert Exprer
}

struct EvaluateStmt {
	body Exprer
}

struct AssignStmt {
	variable_name string
	to_assign     Exprer
}

struct CompileTimeIfStmt {
	cause   string
	content []Stmter
}

struct AppendStmt {
	append_target   Exprer
	value_to_append Exprer
}

struct VariableDeclStmt {
	is_const  bool
	variables map[string]Exprer
}

struct EnumDeclStmt {
	name_of_enum string
	value_names  []string
}

struct StructDeclStmt {
	name_of_struct string
	property       []StructProperty
}

enum StructPropertyAccessModifier {
	public_global_mut
	public_mut
	public_read
	private_mut
	private_read
}

struct StructProperty {
	access_modifier StructPropertyAccessModifier
	field_name      string
	field_type      Typer
}

struct InterfaceDeclStmt {
	name string
	supported_funcs []FunctionDeclExpr
}

struct CommentStmt {
	content string
}

struct BreakStmt {}

struct ContinueStmt {}

struct ReturnStmt {
	value_to_return Exprer
}

struct ImportStmt {
	module_to_import string
}

struct File {
	file_name string
	content   []Stmter
}

struct Module {
	module_path string
	content     []File
}

fn (b BinaryExpr) generate(g Generater, c Context) string {
	return g.binary_expr(b, c)
}

fn (b BinaryExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (i IfExpr) generate(g Generater, c Context) string {
	return g.if_expr(i, c)
}

fn (i IfExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (i IfOptionalExpr) generate(g Generater, c Context) string {
	return g.if_optional_expr(i, c)
}

fn (i IfOptionalExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (f ForBoolExpr) generate(g Generater, c Context) string {
	return g.for_bool_expr(f, c)
}

fn (f ForBoolExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (f ForInExpr) generate(g Generater, c Context) string {
	return g.for_in_expr(f, c)
}

fn (f ForInExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (m MatchExpr) generate(g Generater, c Context) string {
	return g.match_expr(m, c)
}

fn (m MatchExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (c CastExpr) generate(g Generater, ctx Context) string {
	return g.cast_expr(c, ctx)
}

fn (c CastExpr) resolve_type(ctx Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (d DelegateExpr) generate(g Generater, c Context) string {
	return g.delegate_expr(d, c)
}

fn (d DelegateExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (o OrExpr) generate(g Generater, c Context) string {
	return g.or_expr(o, c)
}

fn (o OrExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (f FunctionCallExpr) generate(g Generater, c Context) string {
	return g.function_call_expr(f, c)
}

fn (f FunctionCallExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (p PropertyExpr) generate(g Generater, c Context) string {
	return g.property_expr(p, c)
}

fn (p PropertyExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (n NamespaceExpr) generate(g Generater, c Context) string {
	return g.namespace_expr(n, c)
}

fn (n NamespaceExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (n NoneLiteralExpr) generate(g Generater, c Context) string {
	return g.none_literal_expr(n, c)
}

fn (n NoneLiteralExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (a ArrayLiteralExpr) generate(g Generater, c Context) string {
	return g.array_literal_expr(a, c)
}

fn (a ArrayLiteralExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (b BoolLiteralExpr) generate(g Generater, c Context) string {
	return g.bool_literal_expr(b, c)
}

fn (b BoolLiteralExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (i IntLiteralExpr) generate(g Generater, c Context) string {
	return g.int_literal_expr(i, c)
}

fn (i IntLiteralExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (f FloatLiteralExpr) generate(g Generater, c Context) string {
	return g.float_literal_expr(f, c)
}

fn (f FloatLiteralExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (s StringLiteralExpr) generate(g Generater, c Context) string {
	return g.string_literal_expr(s, c)
}

fn (s StringLiteralExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (s StructExpr) generate(g Generater, c Context) string {
	return g.struct_expr(s, c)
}

fn (s StructExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (s StructModificationExpr) generate(g Generater, c Context) string {
	return g.struct_modification_expr(s, c)
}

fn (s StructModificationExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (f FunctionDeclExpr) generate(g Generater, c Context) string {
	return g.function_decl_expr(f, c)
}

fn (f FunctionDeclExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (v VariableExpr) generate(g Generater, c Context) string {
	return g.variable_expr(v, c)
}

fn (v VariableExpr) resolve_type(c Context) Typer {
	//TODO Finish type system
	return ToDo{}
}

fn (a AssertStmt) generate(g Generater, c Context) string {
	return g.assert_stmt(a, c)
}

fn (e EvaluateStmt) generate(g Generater, c Context) string {
	return g.evaluate_stmt(e, c)
}

fn (a AssignStmt) generate(g Generater, c Context) string {
	return g.assign_stmt(a, c)
}

fn (c CompileTimeIfStmt) generate(g Generater, ctx Context) string {
	return g.compile_time_if_stmt(c, ctx)
}

fn (a AppendStmt) generate(g Generater, c Context) string {
	return g.append_stmt(a, c)
}

fn (v VariableDeclStmt) generate(g Generater, c Context) string {
	return g.variable_decl_stmt(v, c)
}

fn (e EnumDeclStmt) generate(g Generater, c Context) string {
	return g.enum_decl_stmt(e, c)
}

fn (s StructDeclStmt) generate(g Generater, c Context) string {
	return g.struct_decl_stmt(s, c)
}

fn (i InterfaceDeclStmt) generate(g Generater, c Context) string {
	return g.interface_decl_stmt(i, c)
}

fn (c CommentStmt) generate(g Generater, ctx Context) string {
	return g.comment_stmt(c, ctx)
}

fn (b BreakStmt) generate(g Generater, c Context) string {
	return g.break_stmt(b, c)
}

fn (c ContinueStmt) generate(g Generater, ctx Context) string {
	return g.continue_stmt(c, ctx)
}

fn (r ReturnStmt) generate(g Generater, c Context) string {
	return g.return_stmt(r, c)
}

fn (i ImportStmt) generate(g Generater, c Context) string {
	return g.import_stmt(i, c)
}
