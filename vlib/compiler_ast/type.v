module compiler

interface Typer{
	// Super type is basically types that can be effectively replace this type.
	// For example a MutableType can be casted to its non-mutable version safely.
}

struct ToDo {}

enum IntType {
	i8
	i16
	int
	i64
	i128
	byte
	u16
	u32
	u64
	u128
}

enum FloatType {
	f32
	f64
}

struct VoidType {}

struct BoolType {}

struct StringType {}

struct OptionalType {
	underlying Typer
}

struct StructType {
	property_type map[string]Typer
}

struct FunctionType {
	parameters  []Typer
	return_type Typer
}

struct ArrayType {
	element_type Typer
}

struct MapType {
	key_type   Typer
	value_type Typer
}

struct PointerType {
	pointed Typer
}

struct MutableType {
	mutable Typer
}

fn greatest_common_type(left, right Typer) Typer {
	//TODO Finish type system
	return ToDo{}
}
