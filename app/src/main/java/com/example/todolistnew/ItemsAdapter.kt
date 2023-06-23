package com.example.todolistnew

import androidx.recyclerview.widget.RecyclerView
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView.ViewHolder
import com.example.todolist.data.TodoItem

class ItemsAdapter() : RecyclerView.Adapter<ItemHolder>() {

    private var items : MutableList<TodoItem> = mutableListOf<TodoItem>()
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ItemHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        return ItemHolder(layoutInflater.inflate(R.layout.recycle_item, parent, false))
    }

    override fun onBindViewHolder(holder: ItemHolder, position: Int) {
        holder.onBind(items[position])
    }

    override fun getItemCount() = items.size

    fun setList(arr: MutableList<TodoItem>) {
        items.clear()
        items.addAll(arr)
    }
    
    


}



