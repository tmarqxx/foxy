extends Object
class_name NodeUtilities


# Note: passing a value for the type parameter causes a crash
static func get_child_of_type(node: Node, child_type) -> Node:
	if node == null:
		return null
	
	for child in node.get_children():
		if is_instance_of(child, child_type):
			return child
	
	return null


# Note: passing a value for the type parameter causes a crash
static func get_children_of_type(node: Node, child_type):
	if node == null:
		return null
	
	var list = []
	for child in node.get_children():
		if is_instance_of(child, child_type):
			list.append(child)
	return list
