package com.example.todolist.data

import android.content.Context
import androidx.appcompat.content.res.AppCompatResources
import com.example.todolistnew.R


class TodoItemsRepository {

//    private val allItems: MutableList<Item> = mutableListOf<Item>()
//    fun getItems(context: Context): List<Item> {
//        return allItems
//    }
//    fun addItem(item: Item){
//        allItems.add(item)
//    }
//
//    fun deleteItem(item: Item){
//        allItems.remove(item)
//    }
//
//    fun getItem(id: Int): Item?{
//        for (item in allItems){
//            if (item.id == id) return item
//        }
//        return null
//    }

    fun getItems(): MutableList<TodoItem> {
        return mutableListOf(
            TodoItem(
                ItemId = 0,
                Title = "lalalalalal",
                ItemPriority = 1,
                // Set deadline for a week later
                isDone= false,
                ItemTimeOfCreation = "14.05.2022",
                ItemLastChange = "18.04.2023",
                ItemDeadLine = "09.05.2024"
            ),
            TodoItem(
                ItemId = 1,
                Title = "waaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa@",
                ItemPriority = 1,
                // Set deadline for a week later
                isDone= false,
                ItemTimeOfCreation = "14.05.2022",
                ItemLastChange = "18.04.2023",
                ItemDeadLine = "09.05.2024"
            ),
            TodoItem(
                ItemId = 1,
                Title = "",
                ItemPriority = 1,
                // Set deadline for a week later
                isDone= false,
                ItemTimeOfCreation = "14.05.2022",
                ItemLastChange = "18.04.2023",
                ItemDeadLine = "09.05.2024"
            ))

    }
}

