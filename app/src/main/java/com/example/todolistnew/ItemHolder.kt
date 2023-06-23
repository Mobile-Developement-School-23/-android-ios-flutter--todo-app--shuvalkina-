package com.example.todolistnew

import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.example.todolist.data.TodoItem

class ItemHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
    private val itemTitle: TextView = itemView.findViewById(R.id.item_name)

    fun onBind(itemPreview: TodoItem) {
        itemTitle.text = itemPreview.Title
    }
}

