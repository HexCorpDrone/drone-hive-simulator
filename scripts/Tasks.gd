extends Node

# Script for coordinating the completion of tasks.

var exit_box: Node
var tasks = []



func add_task_node(node):
	print("adding " + node.name + " to task list.")
	node.connect("task_complete", self, "task_done")
	node.connect("task_incomplete", self, "task_incomplete")

func task_done(node):
	print("Task completed. :)")
	tasks.remove(tasks.find(node))
	if tasks.empty():
		print("All tasks done!!!!")
		exit_box.trigger_col.disabled = false
		exit_box.all_tasks_complete = true
		exit_box.open()

func task_incomplete(node):
	if tasks.empty() and exit_box != null:
		exit_box.close()
		exit_box.all_tasks_complete = false
		exit_box.trigger_col.disabled = true
	tasks.append(node)