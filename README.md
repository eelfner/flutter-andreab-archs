# andreab_archs

I created this project to show how I'd refactor some excellent work done
by Andrea Bizzotto. He created a demo of 4 different state management techniques
with flutter. There are some similar demonstrations out there, but this one is
right on for being simple and showing the differences. (Although, I do like my 
updates shared in this project.)

Please see his work that this work is built on:
 - [GitHub code](https://github.com/bizz84/multiple-counters-flutter)
 - [YouTube Video](https://youtu.be/HLop7s2sJ7Q)

## Refactorings of Andrea's project

 - Using the Firebase FireStore rather than the Realtime database. Greatly simplified data access.
 - Remove Future's from data access. Not really needed because all updates come through stream.
 - Abstract Database class has more meaningful CRUD method names and ALL access is via this interface.
 - Rename **class Counter** to **class CounterData** and remove id to use auto generated Firebase DocumentId.
 - **bottom_navigation** no longer depends on scoped_model and redux packages. That code has been moved
   to the respective pages.
 -

## REQUIRED SETUP TO USE THIS CODE

You must create and reference a FireStore database. Please see [this other Most Excellent Video by 
Tensor Programming](https://www.youtube.com/watch?v=OJ_u34bD_q8)

## Description of differences between Implementations

#### SetState Example - ListItemsBuilder
 - Stateful Widget
 - Listens to Stream of Counters (CounterValues) triggered by Firestore
 - Subscribe and call setState() when triggered
 - Uses ListItemsBuilder

#### Streams Example - StreamBuilder
 - Stateless Widget
 - Uses StreamBuilder that will automatically build based on snapshot of stream
 - Fairly similar to above SetState, but no longer need to manage subscriptions and call SetState
 - No state management required.

#### ScopedModel Example - ScopedModel
1) Create Model (part of ScopedModel library) that holds data list
1) On update to list, call notifyListeners(). In this case, the stream from firestore is used
   both to get the current data list, and to determine when there are updates.
1) The ScopedModel(Widget) is created with a reference to the Model and with UI (ScopedModelWidget).
 - Now when the model sees and update, it calls notifyListeners() which will trigger the UI to rebuild.
 - This allows you to remove model state out of the widget.

#### Redux Example
 - Made to work, but discussion is beyond scope of this effort.
