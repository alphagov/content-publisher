(function (global, factory) {
  if (typeof define === "function" && define.amd) {
    define(['exports'], factory);
  } else if (typeof exports !== "undefined") {
    factory(exports);
  } else {
    var mod = {
      exports: {}
    };
    factory(mod.exports);
    global.index = mod.exports;
  }
})(this, function (exports) {
  'use strict';

  Object.defineProperty(exports, "__esModule", {
    value: true
  });

  function _possibleConstructorReturn(self, call) {
    if (!self) {
      throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
    }

    return call && (typeof call === "object" || typeof call === "function") ? call : self;
  }

  function _inherits(subClass, superClass) {
    if (typeof superClass !== "function" && superClass !== null) {
      throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
    }

    subClass.prototype = Object.create(superClass && superClass.prototype, {
      constructor: {
        value: subClass,
        enumerable: false,
        writable: true,
        configurable: true
      }
    });
    if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
  }

  function _CustomElement() {
    return Reflect.construct(HTMLElement, [], this.__proto__.constructor);
  }

  ;
  Object.setPrototypeOf(_CustomElement.prototype, HTMLElement.prototype);
  Object.setPrototypeOf(_CustomElement, HTMLElement);

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var _createClass = function () {
    function defineProperties(target, props) {
      for (var i = 0; i < props.length; i++) {
        var descriptor = props[i];
        descriptor.enumerable = descriptor.enumerable || false;
        descriptor.configurable = true;
        if ("value" in descriptor) descriptor.writable = true;
        Object.defineProperty(target, descriptor.key, descriptor);
      }
    }

    return function (Constructor, protoProps, staticProps) {
      if (protoProps) defineProperties(Constructor.prototype, protoProps);
      if (staticProps) defineProperties(Constructor, staticProps);
      return Constructor;
    };
  }();

  function nodesToArray(nodes) {
    return Array.prototype.slice.call(nodes);
  }

  /**
   * This models the taxonomy shown in the miller columns and the current state
   * of it.
   * It notifies the miller columns element when it has changed state to update
   * the UI
   */

  var Taxonomy = function () {
    function Taxonomy(topics, millerColumns) {
      _classCallCheck(this, Taxonomy);

      this.topics = topics;
      this.millerColumns = millerColumns;
      this.active = this.selectedTopics[0];
    }

    /** fetches all the topics that are currently selected */

    // At any time there is one or no active topic, the active topic determines
    // what part of the taxonomy is currently shown to the user (i.e which level)
    // if this is null a user is shown the root column


    _createClass(Taxonomy, [{
      key: 'topicClicked',
      value: function topicClicked(topic) {
        // if this is the active topic or a parent of it we deselect
        if (topic === this.active || topic.parentOf(this.active)) {
          topic.deselect(true);
          this.active = topic.parent;
        } else if (topic.selected || topic.selectedChildren.length) {
          // if this is a selected topic with children we make it active to allow
          // picking the children
          if (topic.children.length) {
            this.active = topic;
          } else {
            // otherwise we deselect it as we know the user can't be traversing
            topic.deselect(true);
            this.active = topic.parent;
          }
        } else {
          // otherwise this is a new selection
          topic.select();
          this.active = topic;
        }

        this.millerColumns.update();
      }
    }, {
      key: 'removeTopic',
      value: function removeTopic(topic) {
        topic.deselect(false);
        // determine which topic to mark as active, if any
        this.active = this.determineActiveFromRemoved(topic);
        this.millerColumns.update();
      }
    }, {
      key: 'determineActiveFromRemoved',
      value: function determineActiveFromRemoved(topic) {
        // if there is already an active item with selected children lets not
        // change anything
        if (this.active && (this.active.selected || this.active.selectedChildren.length)) {
          return this.active;
        }

        // see if there is a parent with selected topics, that feels like the most
        // natural place to end up
        var _iteratorNormalCompletion = true;
        var _didIteratorError = false;
        var _iteratorError = undefined;

        try {
          for (var _iterator = topic.parents.reverse()[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
            var parent = _step.value;

            if (parent.selectedChildren.length) {
              return parent;
            }
          }

          // if we've still not got one we'll go for the first selected one
        } catch (err) {
          _didIteratorError = true;
          _iteratorError = err;
        } finally {
          try {
            if (!_iteratorNormalCompletion && _iterator.return) {
              _iterator.return();
            }
          } finally {
            if (_didIteratorError) {
              throw _iteratorError;
            }
          }
        }

        return this.selectedTopics[0];
      }
    }, {
      key: 'selectedTopics',
      get: function get() {
        return this.topics.reduce(function (memo, topic) {
          if (topic.selected) {
            memo.push(topic);
          }

          return memo.concat(topic.selectedChildren);
        }, []);
      }
    }]);

    return Taxonomy;
  }();

  var Topic = function () {
    _createClass(Topic, null, [{
      key: 'fromList',
      value: function fromList(list) {
        var parent = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : null;

        var topics = [];
        if (!list) {
          return topics;
        }

        var _iteratorNormalCompletion2 = true;
        var _didIteratorError2 = false;
        var _iteratorError2 = undefined;

        try {
          for (var _iterator2 = list.children[Symbol.iterator](), _step2; !(_iteratorNormalCompletion2 = (_step2 = _iterator2.next()).done); _iteratorNormalCompletion2 = true) {
            var item = _step2.value;

            var label = item.querySelector('label');
            var checkbox = item.querySelector('input');
            if (label instanceof HTMLLabelElement && checkbox instanceof HTMLInputElement) {
              var childList = item.querySelector('ul');
              childList = childList instanceof HTMLUListElement ? childList : null;

              var topic = new Topic(label, checkbox, childList, parent);
              topics.push(topic);
            }
          }
        } catch (err) {
          _didIteratorError2 = true;
          _iteratorError2 = err;
        } finally {
          try {
            if (!_iteratorNormalCompletion2 && _iterator2.return) {
              _iterator2.return();
            }
          } finally {
            if (_didIteratorError2) {
              throw _iteratorError2;
            }
          }
        }

        return topics;
      }
    }]);

    function Topic(label, checkbox, childList, parent) {
      _classCallCheck(this, Topic);

      this.label = label;
      this.checkbox = checkbox;
      this.parent = parent;
      this.children = Topic.fromList(childList, this);

      if (!this.children.length && this.checkbox.checked) {
        this.selected = true;
        if (this.parent) {
          this.parent.childWasSelected();
        }
      } else {
        this.selected = false;
      }
    }

    /** The presence of selected children determines whether this item is considered selected */


    _createClass(Topic, [{
      key: 'parentOf',
      value: function parentOf(other) {
        if (!other) {
          return false;
        }

        var _iteratorNormalCompletion3 = true;
        var _didIteratorError3 = false;
        var _iteratorError3 = undefined;

        try {
          for (var _iterator3 = this.children[Symbol.iterator](), _step3; !(_iteratorNormalCompletion3 = (_step3 = _iterator3.next()).done); _iteratorNormalCompletion3 = true) {
            var topic = _step3.value;

            if (topic === other || topic.parentOf(other)) {
              return true;
            }
          }
        } catch (err) {
          _didIteratorError3 = true;
          _iteratorError3 = err;
        } finally {
          try {
            if (!_iteratorNormalCompletion3 && _iterator3.return) {
              _iterator3.return();
            }
          } finally {
            if (_didIteratorError3) {
              throw _iteratorError3;
            }
          }
        }

        return false;
      }
    }, {
      key: 'withParents',
      value: function withParents() {
        return this.parents.concat([this]);
      }
    }, {
      key: 'select',
      value: function select() {
        // if already selected or a child is selected do nothing
        if (this.selected || this.selectedChildren.length) {
          return;
        }
        this.selected = true;
        this.checkbox.checked = true;
        if (this.parent) {
          this.parent.childWasSelected();
        }
      }
    }, {
      key: 'deselect',
      value: function deselect() {
        var selectParent = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : true;

        // if this item is selected explicitly we can deselect it
        if (this.selected) {
          this.deselectSelfAndParents();
        } else {
          // otherwise we need to find the selected children to start deselecting
          var selectedChildren = this.selectedChildren;

          // if we have none it's a no-op
          if (!selectedChildren.length) {
            return;
          }

          var _iteratorNormalCompletion4 = true;
          var _didIteratorError4 = false;
          var _iteratorError4 = undefined;

          try {
            for (var _iterator4 = selectedChildren[Symbol.iterator](), _step4; !(_iteratorNormalCompletion4 = (_step4 = _iterator4.next()).done); _iteratorNormalCompletion4 = true) {
              var child = _step4.value;

              child.deselect(false);
            }
          } catch (err) {
            _didIteratorError4 = true;
            _iteratorError4 = err;
          } finally {
            try {
              if (!_iteratorNormalCompletion4 && _iterator4.return) {
                _iterator4.return();
              }
            } finally {
              if (_didIteratorError4) {
                throw _iteratorError4;
              }
            }
          }
        }

        if (selectParent && this.parent) {
          this.parent.select();
        }
      }
    }, {
      key: 'deselectSelfAndParents',
      value: function deselectSelfAndParents() {
        var _iteratorNormalCompletion5 = true;
        var _didIteratorError5 = false;
        var _iteratorError5 = undefined;

        try {
          // loop through the parents only deselecting items that don't have other
          // selected children
          for (var _iterator5 = this.withParents().reverse()[Symbol.iterator](), _step5; !(_iteratorNormalCompletion5 = (_step5 = _iterator5.next()).done); _iteratorNormalCompletion5 = true) {
            var topic = _step5.value;

            if (topic.selectedChildren.length) {
              break;
            } else {
              topic.selected = false;
              topic.checkbox.checked = false;
            }
          }
        } catch (err) {
          _didIteratorError5 = true;
          _iteratorError5 = err;
        } finally {
          try {
            if (!_iteratorNormalCompletion5 && _iterator5.return) {
              _iterator5.return();
            }
          } finally {
            if (_didIteratorError5) {
              throw _iteratorError5;
            }
          }
        }
      }
    }, {
      key: 'childWasSelected',
      value: function childWasSelected() {
        this.checkbox.checked = true;
        this.selected = false;
        if (this.parent) {
          this.parent.childWasSelected();
        }
      }
    }, {
      key: 'selectedChildren',
      get: function get() {
        return this.children.reduce(function (memo, topic) {
          var selected = topic.selectedChildren;
          if (topic.selected) {
            selected.push(topic);
          }
          return memo.concat(selected);
        }, []);
      }
    }, {
      key: 'parents',
      get: function get() {
        if (this.parent) {
          return this.parent.parents.concat([this.parent]);
        } else {
          return [];
        }
      }
    }]);

    return Topic;
  }();

  var MillerColumnsElement = function (_CustomElement2) {
    _inherits(MillerColumnsElement, _CustomElement2);

    function MillerColumnsElement() {
      _classCallCheck(this, MillerColumnsElement);

      var _this = _possibleConstructorReturn(this, (MillerColumnsElement.__proto__ || Object.getPrototypeOf(MillerColumnsElement)).call(this));

      _this.classNames = {
        column: 'miller-columns__column',
        columnCollapse: 'miller-columns__column--collapse',
        columnNarrow: 'miller-columns__column--narrow',
        item: 'miller-columns__item',
        itemParent: 'miller-columns__item--parent',
        itemActive: 'miller-columns__item--active',
        itemSelected: 'miller-columns__item--selected'
      };
      return _this;
    }

    _createClass(MillerColumnsElement, [{
      key: 'connectedCallback',
      value: function connectedCallback() {
        var source = document.getElementById(this.getAttribute('for') || '');
        if (source) {
          this.taxonomy = new Taxonomy(Topic.fromList(source), this);
          this.renderTaxonomyColumn(this.taxonomy.topics, true);
          this.update();
          if (source.parentNode) {
            source.parentNode.removeChild(source);
          }
          this.style.display = 'block';
        }
      }
    }, {
      key: 'renderTaxonomyColumn',
      value: function renderTaxonomyColumn(topics) {
        var root = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : false;

        var ul = document.createElement('ul');
        ul.className = this.classNames.column;
        if (root) {
          ul.dataset.root = 'true';
        } else {
          ul.classList.add(this.classNames.columnCollapse);
        }
        this.appendChild(ul);
        var _iteratorNormalCompletion6 = true;
        var _didIteratorError6 = false;
        var _iteratorError6 = undefined;

        try {
          for (var _iterator6 = topics[Symbol.iterator](), _step6; !(_iteratorNormalCompletion6 = (_step6 = _iterator6.next()).done); _iteratorNormalCompletion6 = true) {
            var topic = _step6.value;

            this.renderTopic(topic, ul);
          }
        } catch (err) {
          _didIteratorError6 = true;
          _iteratorError6 = err;
        } finally {
          try {
            if (!_iteratorNormalCompletion6 && _iterator6.return) {
              _iterator6.return();
            }
          } finally {
            if (_didIteratorError6) {
              throw _iteratorError6;
            }
          }
        }
      }
    }, {
      key: 'renderTopic',
      value: function renderTopic(topic, list) {
        var li = document.createElement('li');
        li.classList.add(this.classNames.item);
        var div = document.createElement('div');
        div.className = 'govuk-checkboxes__item';
        div.appendChild(topic.checkbox);
        div.appendChild(topic.label);
        li.appendChild(div);
        list.appendChild(li);
        this.attachEvents(li, topic);

        if (topic.children.length) {
          li.classList.add(this.classNames.itemParent);
          this.renderTaxonomyColumn(topic.children);
        }
      }
    }, {
      key: 'attachEvents',
      value: function attachEvents(trigger, topic) {
        var _this2 = this;

        trigger.tabIndex = 0;
        trigger.addEventListener('click', function () {
          return _this2.taxonomy.topicClicked(topic);
        }, false);
        trigger.addEventListener('keydown', function (event) {
          if ([' ', 'Enter'].indexOf(event.key) !== -1) {
            event.preventDefault();
            _this2.taxonomy.topicClicked(topic);
          }
        }, false);
      }
    }, {
      key: 'update',
      value: function update() {
        this.showSelectedTopics(this.taxonomy.selectedTopics);
        this.showActiveTopic(this.taxonomy.active);
        this.showCurrentColumns(this.taxonomy.active);

        if (this.selectedElement) {
          this.selectedElement.update(this.taxonomy);
        }
      }
    }, {
      key: 'updateClassName',
      value: function updateClassName(className, items) {
        var currentlyWithClass = nodesToArray(this.getElementsByClassName(className));

        var _iteratorNormalCompletion7 = true;
        var _didIteratorError7 = false;
        var _iteratorError7 = undefined;

        try {
          for (var _iterator7 = currentlyWithClass.concat(items)[Symbol.iterator](), _step7; !(_iteratorNormalCompletion7 = (_step7 = _iterator7.next()).done); _iteratorNormalCompletion7 = true) {
            var item = _step7.value;

            if (!item) {
              continue;
            }

            if (items.indexOf(item) !== -1) {
              item.classList.add(className);
            } else {
              item.classList.remove(className);
            }
          }
        } catch (err) {
          _didIteratorError7 = true;
          _iteratorError7 = err;
        } finally {
          try {
            if (!_iteratorNormalCompletion7 && _iterator7.return) {
              _iterator7.return();
            }
          } finally {
            if (_didIteratorError7) {
              throw _iteratorError7;
            }
          }
        }
      }
    }, {
      key: 'showSelectedTopics',
      value: function showSelectedTopics(selectedTopics) {
        var _this3 = this;

        var selectedItems = selectedTopics.reduce(function (memo, child) {
          var _iteratorNormalCompletion8 = true;
          var _didIteratorError8 = false;
          var _iteratorError8 = undefined;

          try {
            for (var _iterator8 = child.withParents()[Symbol.iterator](), _step8; !(_iteratorNormalCompletion8 = (_step8 = _iterator8.next()).done); _iteratorNormalCompletion8 = true) {
              var topic = _step8.value;

              var item = topic.checkbox.closest('.' + _this3.classNames.item);
              if (item instanceof HTMLElement) {
                memo.push(item);
              }
            }
          } catch (err) {
            _didIteratorError8 = true;
            _iteratorError8 = err;
          } finally {
            try {
              if (!_iteratorNormalCompletion8 && _iterator8.return) {
                _iterator8.return();
              }
            } finally {
              if (_didIteratorError8) {
                throw _iteratorError8;
              }
            }
          }

          return memo;
        }, []);

        this.updateClassName(this.classNames.itemSelected, selectedItems);
      }
    }, {
      key: 'showActiveTopic',
      value: function showActiveTopic(activeTopic) {
        var _this4 = this;

        var activeItems = void 0;

        if (!activeTopic) {
          activeItems = [];
        } else {
          activeItems = activeTopic.withParents().reduce(function (memo, topic) {
            var item = topic.checkbox.closest('.' + _this4.classNames.item);

            if (item instanceof HTMLElement) {
              memo.push(item);
            }

            return memo;
          }, []);
        }
        this.updateClassName(this.classNames.itemActive, activeItems);
      }
    }, {
      key: 'showCurrentColumns',
      value: function showCurrentColumns(activeTopic) {
        var allColumns = nodesToArray(this.getElementsByClassName(this.classNames.column));
        var columnsToShow = this.columnsForActiveTopic(activeTopic);
        var narrowThreshold = 3;
        var showNarrow = columnsToShow.length > narrowThreshold;
        var _classNames = this.classNames,
            collapseClass = _classNames.columnCollapse,
            narrowClass = _classNames.columnNarrow;
        var _iteratorNormalCompletion9 = true;
        var _didIteratorError9 = false;
        var _iteratorError9 = undefined;

        try {

          for (var _iterator9 = allColumns[Symbol.iterator](), _step9; !(_iteratorNormalCompletion9 = (_step9 = _iterator9.next()).done); _iteratorNormalCompletion9 = true) {
            var item = _step9.value;

            if (!item) {
              continue;
            }

            // we always want to show the root column
            if (item.dataset.root === 'true') {
              showNarrow ? item.classList.add(narrowClass) : item.classList.remove(narrowClass);
              continue;
            }

            var index = columnsToShow.indexOf(item);

            if (index === -1) {
              // this is not a column to show
              item.classList.add(collapseClass);
            } else if (showNarrow && index < narrowThreshold) {
              // show this column but narrow
              item.classList.remove(collapseClass);
              item.classList.add(narrowClass);
            } else {
              // show this column in all it's glory
              item.classList.remove(collapseClass, narrowClass);
            }
          }
        } catch (err) {
          _didIteratorError9 = true;
          _iteratorError9 = err;
        } finally {
          try {
            if (!_iteratorNormalCompletion9 && _iterator9.return) {
              _iterator9.return();
            }
          } finally {
            if (_didIteratorError9) {
              throw _iteratorError9;
            }
          }
        }
      }
    }, {
      key: 'columnsForActiveTopic',
      value: function columnsForActiveTopic(activeTopic) {
        if (!activeTopic) {
          return [];
        }

        var columnSelector = '.' + this.classNames.column;
        var columns = activeTopic.withParents().reduce(function (memo, topic) {
          var column = topic.checkbox.closest(columnSelector);
          if (column instanceof HTMLElement) {
            memo.push(column);
          }

          return memo;
        }, []);

        // we'll want to show the next column too for the next choices
        if (activeTopic.children.length) {
          var nextColumn = activeTopic.children[0].checkbox.closest(columnSelector);
          if (nextColumn instanceof HTMLElement) {
            columns.push(nextColumn);
          }
        }
        return columns;
      }
    }, {
      key: 'selectedElement',
      get: function get() {
        var selected = document.getElementById(this.getAttribute('selected') || '');
        return selected instanceof MillerColumnsSelectedElement ? selected : null;
      }
    }]);

    return MillerColumnsElement;
  }(_CustomElement);

  var MillerColumnsSelectedElement = function (_CustomElement3) {
    _inherits(MillerColumnsSelectedElement, _CustomElement3);

    function MillerColumnsSelectedElement() {
      _classCallCheck(this, MillerColumnsSelectedElement);

      return _possibleConstructorReturn(this, (MillerColumnsSelectedElement.__proto__ || Object.getPrototypeOf(MillerColumnsSelectedElement)).call(this));
    }

    _createClass(MillerColumnsSelectedElement, [{
      key: 'connectedCallback',
      value: function connectedCallback() {
        this.list = document.createElement('ol');
        this.list.className = 'miller-columns-selected__list';
        this.appendChild(this.list);
        if (this.millerColumnsElement && this.millerColumnsElement.taxonomy) {
          this.update(this.millerColumnsElement.taxonomy);
        }
      }
    }, {
      key: 'update',
      value: function update(taxonomy) {
        this.taxonomy = taxonomy;
        var selectedTopics = taxonomy.selectedTopics;
        // seems simpler to nuke the list and re-build it
        while (this.list.lastChild) {
          this.list.removeChild(this.list.lastChild);
        }

        if (selectedTopics.length) {
          var _iteratorNormalCompletion10 = true;
          var _didIteratorError10 = false;
          var _iteratorError10 = undefined;

          try {
            for (var _iterator10 = selectedTopics[Symbol.iterator](), _step10; !(_iteratorNormalCompletion10 = (_step10 = _iterator10.next()).done); _iteratorNormalCompletion10 = true) {
              var topic = _step10.value;

              this.addSelectedTopic(topic);
            }
          } catch (err) {
            _didIteratorError10 = true;
            _iteratorError10 = err;
          } finally {
            try {
              if (!_iteratorNormalCompletion10 && _iterator10.return) {
                _iterator10.return();
              }
            } finally {
              if (_didIteratorError10) {
                throw _iteratorError10;
              }
            }
          }
        } else {
          var li = document.createElement('li');
          li.className = 'miller-columns-selected__list-item';
          li.textContent = 'No selected topics';
          this.list.appendChild(li);
        }
      }
    }, {
      key: 'addSelectedTopic',
      value: function addSelectedTopic(topic) {
        var li = document.createElement('li');
        li.className = 'miller-columns-selected__list-item';
        li.appendChild(this.breadcrumbsElement(topic));
        li.appendChild(this.removeTopicElement(topic));
        this.list.appendChild(li);
      }
    }, {
      key: 'breadcrumbsElement',
      value: function breadcrumbsElement(topic) {
        var div = document.createElement('div');
        div.className = 'govuk-breadcrumbs';
        var ol = document.createElement('ol');
        ol.className = 'govuk-breadcrumbs__list';
        var _iteratorNormalCompletion11 = true;
        var _didIteratorError11 = false;
        var _iteratorError11 = undefined;

        try {
          for (var _iterator11 = topic.withParents()[Symbol.iterator](), _step11; !(_iteratorNormalCompletion11 = (_step11 = _iterator11.next()).done); _iteratorNormalCompletion11 = true) {
            var current = _step11.value;

            var li = document.createElement('li');
            li.className = 'govuk-breadcrumbs__list-item';
            li.textContent = current.label.textContent;
            ol.appendChild(li);
          }
        } catch (err) {
          _didIteratorError11 = true;
          _iteratorError11 = err;
        } finally {
          try {
            if (!_iteratorNormalCompletion11 && _iterator11.return) {
              _iterator11.return();
            }
          } finally {
            if (_didIteratorError11) {
              throw _iteratorError11;
            }
          }
        }

        div.appendChild(ol);
        return div;
      }
    }, {
      key: 'removeTopicElement',
      value: function removeTopicElement(topic) {
        var _this6 = this;

        var button = document.createElement('button');
        button.className = 'miller-columns-selected__remove-topic';
        button.textContent = 'Remove topic';
        button.setAttribute('type', 'button');
        button.addEventListener('click', function () {
          if (_this6.taxonomy) {
            _this6.taxonomy.removeTopic(topic);
          }
        });
        return button;
      }
    }, {
      key: 'millerColumnsElement',
      get: function get() {
        var millerColumns = document.getElementById(this.getAttribute('for') || '');
        return millerColumns instanceof MillerColumnsElement ? millerColumns : null;
      }
    }]);

    return MillerColumnsSelectedElement;
  }(_CustomElement);

  if (!window.customElements.get('miller-columns')) {
    window.MillerColumnsElement = MillerColumnsElement;
    window.customElements.define('miller-columns', MillerColumnsElement);
  }

  if (!window.customElements.get('miller-columns-selected')) {
    window.MillerColumnsSelectedElement = MillerColumnsSelectedElement;
    window.customElements.define('miller-columns-selected', MillerColumnsSelectedElement);
  }

  exports.MillerColumnsElement = MillerColumnsElement;
  exports.MillerColumnsSelectedElement = MillerColumnsSelectedElement;
});
