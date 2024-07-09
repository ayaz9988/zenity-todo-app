#!/bin/bash
DB_PATH="$HOME/.todo.txt"
# Function to add a task
add_task() {
  task=$(zenity --entry --text="Enter task description:")
  if [[ -z "$task" ]]; then
    return 1
  fi
  priority=$(zenity --list --radiolist --title "Select Priority" --column "Selection" --column "Priority" FALSE "🟥 High" TRUE "🟨 Medium" FALSE "🟩 Low")
  if [[ -z "$priority" ]]; then
    return 1
  fi
  echo "$task ($priority)" >> $DB_PATH
  zenity --info --title="Success" --text="Task added successfully!"
}
# Function to complete a task
complete_task() {
  display_tasks
  task_num=$(zenity --entry --text="Enter task number to complete:")
  if [[ ! $task_num =~ ^[0-9]+$ ]]; then
    zenity --error --title="Error" --text="Invalid task number."
    return 1
  fi
  # Find the task line based on task number
  task_line=$(cat $DB_PATH | nl -s ":" | grep "$task_num" | cut -d ':' -f 1)
  if [[ -z "$task_line" ]]; then
    zenity --error --title="Error" --text="Task number $task_num does not exist."
    return 1
  fi
  # Check if the task is already completed
  if grep -q "^✅" <<< "$(sed -n "$task_line p" $DB_PATH)"; then
    # Unmark the task
    sed -i "$task_line s/^✅\(.*\)/\1/" $DB_PATH
    zenity --info --title="Success" --text="Task marked as incomplete!"
  else
    # Mark the task as complete
    sed -i "$task_line s/^\(.*\)/✅\1/" $DB_PATH
    zenity --info --title="Success" --text="Task marked as complete!"
  fi
}
# Function to delete a task
delete_task() {
  display_tasks
  task_num=$(zenity --entry --text="Enter task number to delete:")
  if [[ ! $task_num =~ ^[0-9]+$ ]]; then
    zenity --error --title="Error" --text="Invalid task number."
    return 1
  fi
  # Find the task line based on task number
  task_line=$(cat $DB_PATH | nl -s ":" | grep "$task_num" | cut -d ':' -f 1)
  if [[ -z "$task_line" ]]; then
    zenity --error --title="Error" --text="Task number $task_num does not exist."
    return 1
  fi
  sed -i "$task_line d" $DB_PATH
  zenity --info --title="Success" --text="Task deleted!"
}
# Function to sort tasks by priority
sort_tasks() {
  sort -t '(' -k 2 $DB_PATH > $HOME/.temp.txt
  mv $HOME/.temp.txt $DB_PATH
  zenity --info --title="Success" --text="Tasks sorted by priority!"
}
# Function to display tasks
display_tasks() {
  if [ -s $DB_PATH ]; then
    # Use a counter for task numbers
    i=1
    tasks=""
    while read -r line; do
      tasks="$tasks$i) $line\n"
      ((i++))
    done < "$DB_PATH"
    zenity --info --title="To-Do List" --width 500 --text="$tasks"
  else
    zenity --info --title="To-Do List" --text="No tasks yet."
  fi
}
# Main loop
while true; do
  choice=$(zenity --height 80 --question --text="What do you want to do?" \
    --switch \
    --title="To-Do List" \
    --extra-button="Quit" \
    --extra-button="View Tasks" \
    --extra-button="Sort Tasks" \
    --extra-button="Delete Task" \
    --extra-button="Complete Task" \
    --extra-button="Add Task")
  case "$choice" in
    "Add Task")
      add_task
      ;;
    "Complete Task")
      complete_task
      ;;
    "Delete Task")
      delete_task
      ;;
    "Sort Tasks")
      sort_tasks
      ;;
    "View Tasks")
      display_tasks
      ;;
    "Quit")
      exit 0
      ;;
  esac
done
