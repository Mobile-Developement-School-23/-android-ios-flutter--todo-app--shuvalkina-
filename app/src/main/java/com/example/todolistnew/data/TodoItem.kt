package com.example.todolist.data

import android.content.ClipData
import android.graphics.drawable.Drawable
import androidx.annotation.StringRes
import java.util.Date

//sealed class Item(
//    val id: Int
//)

object Priority {
    val LOW = 1
    val NORMAL = 2
    val HIGH = 3
}
data class TodoItem (
    val ItemId: Int,
    val Title: String,
//    val Description: String,
    val ItemPriority: Int,
    val ItemTimeOfCreation: String,
    val ItemLastChange: String,
    val ItemDeadLine: String,
    val isDone: Boolean



    )
