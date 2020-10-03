tool
class_name ScnList
extends Resource

# The resource which saves the data of the palette.
# Contains categories, paths to icons and scenes.

export(String) var last_category = "" 

const empty_category = {
	"Name":"Category",
	"Icon":"",
	"Scenes":[],
}

export(Dictionary) var list = {
	"Category":{
		"Name":"Category",
		"Icon":"",
		"Scenes":[],
	},
}


# Add scene "v" to "category"
func add_scn(category,v):
	if !has_scn(category,v):
		list[category]["Scenes"].append(v)


# Remove scene "v" to "category"
func remove_scn(category,v):
	var scenes = get_scenes(category)
	var id = scenes.find(v)
	if scenes.size() >= id:
		list[category]["Scenes"].remove(id)


func has_scn(category,v)-> bool: 
	 return(list[category]["Scenes"].find(v) != -1)


func get_scenes(category):
	return(list[category]["Scenes"].duplicate())


func has_category(category):
	return(list.has(category))


	# Generate a category after using the "add category" button
func generate_category(data):
	var new_data = data.duplicate()
	for key in empty_category:
		if !new_data.has(key):
			new_data[key] = empty_category[key].duplicate()
	list[new_data["Name"]] = new_data


# Remove a category after using the "remove category" button
func remove_category(category):
	if has_category(category):
		list.erase(category)


# Update a category after using the "edit category" button
func edit_category(old_name,data):
	var new_data = data.duplicate()
	new_data["Scenes"] = list[old_name]["Scenes"].duplicate()
	list.erase(old_name) 
	for key in empty_category:
		if !new_data.has(key):
			new_data[key] = empty_category[key]
	list[data["Name"]] = new_data.duplicate()


# Update the paths when the files were moved
func update_ref(change):
	var old = change["old"]
	var new = change["new"]
	var ref_changed_count = 0
	for key in list:
		if list[key]["Icon"] == old:
			list[key]["Icon"] = new
			ref_changed_count += 1
		for i in list[key]["Scenes"].size():
			if list[key]["Scenes"][i] == old:
				list[key]["Scenes"][i] = new
				ref_changed_count += 1
