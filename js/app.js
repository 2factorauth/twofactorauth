(function (root, $) {
    $('.menu .dropdown').dropdown();
}(window, jQuery));

(function (root, $) {
	var options = {
		localStorage: false,
		storedState: {
			todoInit: false,
			completed: [],
			todo: []
		},
		controlButton: null,
		sectionsParent: null,
		sidebar: null,
		websites: null,
		taskTemplate: null,
		undoAction: [],
		undoActionObject: [],
		redoAction: [],
		redoActionObject: []
	};
	var init = function () {
		options.websites = $(".website");
		options.sectionsParent = $("#sections");
		options.controlButton = $("#toggleTodo");
		options.sidebar = $(".todo.sidebar");
		var completionTogglerTemplate = $("<div>").addClass("completionToggler").html('<i class="empty large checkbox icon"></i><i class="remove large icon black"></i>');
		options.taskTemplate = $("<div>").addClass("item").addClass("task").html(completionTogglerTemplate.clone());
		options.localStorage = supports_html5_storage();
		if(options.localStorage) {
			loadFromStorage();
		}
		if(options.storedState.todoInit) {
			options.controlButton.toggleClass("active").toggleClass("inactive");
			options.sectionsParent.toggleClass("active");
			$(options.sidebar).sidebar('toggle');

		}
		initBinds();
	};
	var loadFromStorage = function () {
		console.log("loading from storage");
		var json = localStorage.getItem("todoState");
		var state = $.parseJSON(json);
		if(state) {
			options.storedState = state;
			var i;
			for(i = 0; state.todo.length > i; i++) {
				var website = $("#"+ state.todo[i]);
				console.log(state.todo[i]);
				addWebsite2Todo(website);
				website.toggleClass("hidden");
				toggleSectionVisibility(website);
			}
			for(i = 0; state.completed.length > i; i++) {
				var task = $("#task" + state.completed[i]);
				console.log(state.completed[i]);
				task.find(".checkbox").toggleClass("empty").toggleClass("checked");
				task.toggleClass("completed");
			}
		}
	};
	var storeInStorage = function () {
		if(!options.localStorage) return false;
		localStorage.setItem("todoState", JSON.stringify(options.storedState));
	};
	var initBinds = function () {
		$(window).on('keydown', function (event){
			if((event.metaKey || event.ctrlKey) && event.keyCode === 90) {
				if(event.shiftKey)
					redo();
				else
					undo();
			}
		});
		options.controlButton.on('click', toggleTodo);
		options.websites.on('click', toggleWebsite);
		options.sidebar.on('click', '.completionToggler>.remove', removeTaskFromTodo);
		options.sidebar.on('click', '.completionToggler>.checkbox', toggleTask);
	};
	var toggleTodo = function (){
		options.controlButton.toggleClass("active").toggleClass("inactive");
		options.sectionsParent.toggleClass("active");
		options.storedState.todoInit = !options.storedState.todoInit;
		$(options.sidebar).sidebar('toggle');
		storeInStorage();
	};
	var toggleWebsite = function (event) {
		if(options.storedState.todoInit){
			event.preventDefault();
			var website = $(event.currentTarget);
			if(website.children(".main.positive").length > 0) {
				//We only add websites that support 2FA.
				toggleTaskAddition(website);
				clearRedoQueue();
				options.undoActionObject.push(website);
				options.undoAction.push(toggleTaskAddition);
			}
		}
	};
	var toggleSectionVisibility = function (website) {
		var section = website.closest(".section");
		var length = section.find(".website:not(.hidden)").length;
		if(length===0) {
			section.addClass("hidden");
		} else {
			section.removeClass("hidden");
		}
	};
	var toggleTaskAddition = function (website) {
		if(website.hasClass("hidden")) {
			removeWebsiteFromTodo(website);
			removeStoredTodo(website);
		} else {
			addWebsite2Todo(website);
			addStoredTodo(website);
		}
		website.toggleClass("hidden");
		toggleSectionVisibility(website);

	};
	var addStoredTodo = function (website) {
		options.storedState.todo.push(website.attr("id"));
		storeInStorage();
	};
	var removeStoredTodo = function (website) {
		var id = website.attr("id");
		var todoIndex = options.storedState.todo.indexOf(id);
		if(todoIndex != -1) {
			var completedIndex = options.storedState.completed.indexOf(id);
			if(completedIndex != -1) {
				options.storedState.completed.slice(completedIndex, 1);
			}
			options.storedState.todo.slice(todoIndex, 1);
		}
		storeInStorage();
	};
	var addWebsite2Todo = function (website) {
		var completionToggler = $("<div>").addClass("completionToggler");
		var children = website.children("td");
		var child2 = $(children.get(1)).html();
		var child1 = children.first().html();
		var id = "task" + website.attr("id");
		var item = options.taskTemplate.clone().attr("id",id).prepend(child2).prepend(child1);
		options.sidebar.append(item);
	};
	var removeTaskFromTodo = function (event) {
		var task = $(event.currentTarget).closest(".item.task");
		var id = task.attr("id");
		id = id.substr(4, id.length);
		var website = $("#"+id);
		task.remove();
		options.undoActionObject.push(website);
		options.undoAction.push(toggleTaskAddition);
		clearRedoQueue();
		toggleTaskAddition(website);
	};
	var removeWebsiteFromTodo = function (website) {
		$("#task"+website.attr("id")).remove();
	};
	var toggleTask = function (event) {
		var task = $(event.currentTarget).closest(".item.task");
		options.undoActionObject.push(task);
		options.undoAction.push(toggleTaskCompletion);
		clearRedoQueue();
		toggleTaskCompletion(task);
	};
	var toggleTaskCompletion = function (task) {
		var id = task.attr("id");
		id = id.substr(4, id.length);
		if(task.hasClass("completed")){
			removeStoredCompletion(id);
		} else {
			addStoredCompletion(id);
		}
		task.find(".checkbox").toggleClass("empty").toggleClass("checked");
		task.toggleClass("completed");
	};
	var removeStoredCompletion = function (id) {
		var completedIndex = options.storedState.completed.indexOf(id);
		if(completedIndex != -1) {
			options.storedState.completed.slice(completedIndex, 1);
		}
		storeInStorage();
	};
	var addStoredCompletion = function (id) {
		options.storedState.completed.push(id);
		storeInStorage();
	};
	var undo = function () {
		if(options.undoAction.length === 0 || options.undoActionObject.length === 0) return;
		var func = options.undoAction.pop();
		var args = options.undoActionObject.pop();
		options.redoAction.push(func);
		options.redoActionObject.push(args);
		func(args);
	};
	var redo = function () {
		if(options.redoAction.length === 0 || options.redoActionObject.length === 0) return;
		var func = options.redoAction.pop();
		var args = options.redoActionObject.pop();
		options.undoAction.push(func);
		options.undoActionObject.push(args);
		func(args);
	};
	var clearRedoQueue = function () {
		options.redoAction = [];
		options.redoActionObject = [];
	};
	var supports_html5_storage = function () {
		try {
			return 'localStorage' in window && window['localStorage'] !== null;
		} catch (e) {
			return false;
		}
	};
	init();
}(window, jQuery));


