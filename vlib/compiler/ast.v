module compiler

enum NodeType {
	assign_statement
	if_expression
	index_epxression
	string_literal

}

interface Noder {
	str() string
	typ() NodeType
}

