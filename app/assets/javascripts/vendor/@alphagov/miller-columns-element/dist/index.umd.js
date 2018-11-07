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

  var _slicedToArray = function () {
    function sliceIterator(arr, i) {
      var _arr = [];
      var _n = true;
      var _d = false;
      var _e = undefined;

      try {
        for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) {
          _arr.push(_s.value);

          if (i && _arr.length === i) break;
        }
      } catch (err) {
        _d = true;
        _e = err;
      } finally {
        try {
          if (!_n && _i["return"]) _i["return"]();
        } finally {
          if (_d) throw _e;
        }
      }

      return _arr;
    }

    return function (arr, i) {
      if (Array.isArray(arr)) {
        return arr;
      } else if (Symbol.iterator in Object(arr)) {
        return sliceIterator(arr, i);
      } else {
        throw new TypeError("Invalid attempt to destructure non-iterable instance");
      }
    };
  }();

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

  var MillerColumnsElement = function (_CustomElement2) {
    _inherits(MillerColumnsElement, _CustomElement2);

    function MillerColumnsElement() {
      _classCallCheck(this, MillerColumnsElement);

      return _possibleConstructorReturn(this, (MillerColumnsElement.__proto__ || Object.getPrototypeOf(MillerColumnsElement)).call(this));
    }

    _createClass(MillerColumnsElement, [{
      key: 'connectedCallback',
      value: function connectedCallback() {
        // A nested tree list with all items
        var list = this.list;

        // Set default values
        this.dataset.chain = '0';
        this.dataset.depth = '0';
        this.dataset.level = '0';

        // Show the columns
        this.style.display = 'block';

        if (list) {
          // Store checked inputs
          var checkboxes = this.checkboxes;

          // Attach click events for list items
          this.attachClickEvents(list);

          // Load checkbox ids as data-id for list items
          if (checkboxes) {
            this.loadIds(checkboxes);
          }

          // Unnest the tree list into columns
          this.unnest(list);
        }
      }
    }, {
      key: 'disconnectedCallback',
      value: function disconnectedCallback() {}
    }, {
      key: 'getItemLevel',
      value: function getItemLevel(item) {
        var column = item.closest('ul');
        var level = '0';
        if (column instanceof HTMLUListElement) {
          level = this.getLevel(column).toString();
        }
        return level;
      }
    }, {
      key: 'getItemParent',
      value: function getItemParent(item) {
        var column = item.closest('ul');
        // $FlowFixMe
        var parent = document.querySelector('[data-id="' + column.dataset.parent + '"]');
        return parent;
      }
    }, {
      key: 'getChain',
      value: function getChain(chain) {
        return Array.prototype.slice.call(this.querySelectorAll('.govuk-miller-columns__column li[data-chain="' + chain + '"]'));
      }
    }, {
      key: 'getSelectedItems',
      value: function getSelectedItems(level) {
        return Array.prototype.slice.call(this.querySelectorAll('.govuk-miller-columns__column[data-level="' + level + '"] li[data-selected="true"]'));
      }
    }, {
      key: 'getAncestors',
      value: function getAncestors(item) {
        var ancestors = [];
        // item = this.getItemParent(item)
        while (item) {
          if (item instanceof HTMLElement) {
            ancestors.push(item);
            item = this.getItemParent(item);
          }
        }
        return ancestors.reverse();
      }
    }, {
      key: 'getAllColumns',
      value: function getAllColumns() {
        return Array.prototype.slice.call(this.querySelectorAll('.govuk-miller-columns__column'));
      }
    }, {
      key: 'getLevel',
      value: function getLevel(column) {
        return parseInt(column.dataset.level);
      }
    }, {
      key: 'loadCheckboxes',
      value: function loadCheckboxes(inputs) {
        var _iteratorNormalCompletion = true;
        var _didIteratorError = false;
        var _iteratorError = undefined;

        try {
          for (var _iterator = inputs[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
            var input = _step.value;

            var li = input.closest('li');
            if (li instanceof HTMLLIElement) {
              li.dispatchEvent(new MouseEvent('click'));
              if (this.breadcrumbs) {
                this.breadcrumbs.storeActiveChain();
                this.dataset.chain = (chains.length + 1).toString();
              }
            }
          }
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
      }
    }, {
      key: 'loadIds',
      value: function loadIds(inputs) {
        var _iteratorNormalCompletion2 = true;
        var _didIteratorError2 = false;
        var _iteratorError2 = undefined;

        try {
          for (var _iterator2 = inputs[Symbol.iterator](), _step2; !(_iteratorNormalCompletion2 = (_step2 = _iterator2.next()).done); _iteratorNormalCompletion2 = true) {
            var input = _step2.value;

            var li = input.closest('li');
            if (li instanceof HTMLLIElement) {
              li.dataset.id = input.id;
              li.classList.add('govuk-miller-columns__item');
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
      }
    }, {
      key: 'unnest',
      value: function unnest(root) {
        var millercolumns = this;

        var queue = [];
        var node = void 0;
        var listItems = void 0;
        var depth = 1;

        // Push the root unordered list item into the queue.
        root.className = 'govuk-miller-columns__column';
        root.dataset.level = '1';
        queue.push(root);

        while (queue.length) {
          node = queue.shift();

          if (node.children) {
            listItems = node.children;

            var _iteratorNormalCompletion3 = true;
            var _didIteratorError3 = false;
            var _iteratorError3 = undefined;

            try {
              for (var _iterator3 = listItems[Symbol.iterator](), _step3; !(_iteratorNormalCompletion3 = (_step3 = _iterator3.next()).done); _iteratorNormalCompletion3 = true) {
                var listItem = _step3.value;

                var descendants = listItem.querySelector('ul');
                var ancestor = listItem;

                if (descendants) {
                  // Store level and depth.
                  var level = parseInt(node.dataset.level) + 1;
                  descendants.dataset.level = level.toString();
                  if (level > depth) depth = level;

                  queue.push(descendants);

                  if (ancestor) {
                    // Mark list items with descendants as parents.
                    ancestor.dataset.parent = 'true';
                    ancestor.classList.add('govuk-miller-columns__item--parent');

                    // Expand the descendants list on click.
                    var fn = this.toggleColumn.bind(null, this, ancestor, descendants);
                    ancestor.addEventListener('click', fn, false);

                    // Attach event listeners.
                    var keys = [' ', 'Enter'];
                    ancestor.addEventListener('keydown', this.keydown(fn, keys), false);
                  }

                  // Hide columns.
                  descendants.dataset.collapse = 'true';
                  descendants.dataset.parent = ancestor.dataset.id;
                  descendants.className = 'govuk-miller-columns__column govuk-miller-columns__column--collapse';
                  // Causes item siblings to have a flattened DOM lineage.
                  millercolumns.insertAdjacentElement('beforeend', descendants);
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
          }
        }

        this.dataset.depth = depth.toString();
      }
    }, {
      key: 'attachClickEvents',
      value: function attachClickEvents(root) {
        var items = root.querySelectorAll('li');

        var _iteratorNormalCompletion4 = true;
        var _didIteratorError4 = false;
        var _iteratorError4 = undefined;

        try {
          for (var _iterator4 = items[Symbol.iterator](), _step4; !(_iteratorNormalCompletion4 = (_step4 = _iterator4.next()).done); _iteratorNormalCompletion4 = true) {
            var item = _step4.value;

            var fn = this.clickItem.bind(null, this, item);
            item.addEventListener('click', fn, false);

            var keys = [' ', 'Enter'];
            item.addEventListener('keydown', this.keydown(fn, keys));

            item.tabIndex = 0;
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
    }, {
      key: 'keydown',
      value: function keydown(fn, keys) {
        return function (event) {
          if (keys.indexOf(event.key) >= 0) {
            event.preventDefault();
            fn(event);
          }
        };
      }
    }, {
      key: 'clickItem',
      value: function clickItem(millercolumns, item) {
        // Set the current level
        var currentLevel = millercolumns.getItemLevel(item);
        var previousLevel = millercolumns.dataset.level;

        // Determine existing selections on the column
        var selectedItems = millercolumns.getSelectedItems(currentLevel);

        millercolumns.dataset.level = currentLevel;

        if (!(millercolumns.breadcrumbs instanceof BreadcrumbsElement)) return;

        // If selecting an upper level or a new item on the same level
        // and not selected nor stored we start a new chain
        if ((currentLevel < previousLevel || selectedItems.length > 0) && item.dataset.selected !== 'true' && item.dataset.stored !== 'true') {
          // Store active chain
          millercolumns.breadcrumbs.storeActiveChain();
          // Increment chain index
          millercolumns.dataset.chain = chains.length.toString();
          // Default item click
          item.dataset.chain = millercolumns.dataset.chain;
          // Retrieve ancestors
          var ancestors = millercolumns.getAncestors(item);
          if (ancestors) {
            millercolumns.selectItems(ancestors, item.dataset.chain);
          }

          if (item.dataset.selected !== 'true' && item.dataset.stored !== 'true') {
            millercolumns.toggleItem(item);
          }
        } else if (item.dataset.stored === 'true') {
          // If click on a stored item we swap the active chain and not toggle
          millercolumns.breadcrumbs.storeActiveChain();
          // Make stored chain active
          millercolumns.dataset.chain = item.dataset.chain;
          // $FlowFixMe
          millercolumns.breadcrumbs.swapActiveChain();
          // Retrieve ancestors
          var _ancestors = millercolumns.getAncestors(item);
          if (_ancestors) {
            millercolumns.selectItems(_ancestors, item.dataset.chain);
          }
        } else {
          // Default item click
          item.dataset.chain = millercolumns.dataset.chain;

          if (item.dataset.selected !== 'true' && item.dataset.stored !== 'true') {
            // If not selected nor stored retrieve ancestors and select
            var _ancestors2 = millercolumns.getAncestors(item);
            if (_ancestors2) {
              millercolumns.selectItems(_ancestors2, item.dataset.chain);
            }
          } else {
            // If selected toggle to remove
            millercolumns.toggleItem(item);
          }
        }

        // If not a parent hide residual descendants list
        if (item.dataset.parent !== 'true') {
          millercolumns.hideColumns((parseInt(currentLevel) + 1).toString());
        }

        // Update active chain to reflect selection
        millercolumns.breadcrumbs.updateActiveChain();
      }
    }, {
      key: 'toggleItem',
      value: function toggleItem(item) {
        if (item.dataset.selected === 'true') {
          this.deselectItem(item);
        } else {
          this.selectItem(item);
        }
      }
    }, {
      key: 'selectItem',
      value: function selectItem(item) {
        item.dataset.selected = 'true';
        item.classList.add('govuk-miller-columns__item--selected');

        var input = item.querySelector('input[type=checkbox]');
        if (input) {
          input.setAttribute('checked', 'checked');
        }
      }
    }, {
      key: 'selectItems',
      value: function selectItems(items, index) {
        var _iteratorNormalCompletion5 = true;
        var _didIteratorError5 = false;
        var _iteratorError5 = undefined;

        try {
          for (var _iterator5 = items[Symbol.iterator](), _step5; !(_iteratorNormalCompletion5 = (_step5 = _iterator5.next()).done); _iteratorNormalCompletion5 = true) {
            var item = _step5.value;

            this.selectItem(item);
            item.dataset.chain = index;
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
      key: 'deselectItem',
      value: function deselectItem(item) {
        item.dataset.selected = 'false';
        item.dataset.stored = 'false';
        item.removeAttribute('data-chain');
        item.classList.remove('govuk-miller-columns__item--selected');
        item.classList.remove('govuk-miller-columns__item--stored');

        var input = item.querySelector('input[type=checkbox]');
        if (input) {
          input.removeAttribute('checked');
        }
      }
    }, {
      key: 'toggleColumn',
      value: function toggleColumn(millercolumns, item, column) {
        millercolumns.hideColumns(column.dataset.level);
        if (item.dataset.selected === 'true' || item.dataset.stored === 'true') {
          column.dataset.collapse = 'false';
          column.classList.remove('govuk-miller-columns__column--collapse');
          millercolumns.animateColumns(column);
        } else {
          // Ensure children are removed
          millercolumns.removeAllChildren(column.dataset.level);
        }
      }
    }, {
      key: 'hideColumns',
      value: function hideColumns(level) {
        var levelInt = parseInt(level);
        var depth = this.depth;
        var columnSelectors = [];

        for (var i = levelInt; i <= depth; i++) {
          columnSelectors.push('[data-level=\'' + i.toString() + '\']');
        }

        var lists = this.querySelectorAll(columnSelectors.join(', '));
        var _iteratorNormalCompletion6 = true;
        var _didIteratorError6 = false;
        var _iteratorError6 = undefined;

        try {
          for (var _iterator6 = lists[Symbol.iterator](), _step6; !(_iteratorNormalCompletion6 = (_step6 = _iterator6.next()).done); _iteratorNormalCompletion6 = true) {
            var item = _step6.value;

            item.dataset.collapse = 'true';
            item.classList.add('govuk-miller-columns__column--collapse');
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

        this.resetAnimation(levelInt);
      }
    }, {
      key: 'removeAllChildren',
      value: function removeAllChildren(level) {
        var millercolumns = this;
        var levelInt = parseInt(level);
        var depth = this.depth;
        var itemSelectors = [];

        for (var i = levelInt; i <= depth; i++) {
          itemSelectors.push('[data-level=\'' + i.toString() + '\'] li');
        }

        var items = millercolumns.querySelectorAll(itemSelectors.join(', '));
        var _iteratorNormalCompletion7 = true;
        var _didIteratorError7 = false;
        var _iteratorError7 = undefined;

        try {
          for (var _iterator7 = items[Symbol.iterator](), _step7; !(_iteratorNormalCompletion7 = (_step7 = _iterator7.next()).done); _iteratorNormalCompletion7 = true) {
            var item = _step7.value;

            millercolumns.deselectItem(item);
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

        if (millercolumns.breadcrumbs) {
          millercolumns.breadcrumbs.updateActiveChain();
        }
      }
    }, {
      key: 'animateColumns',
      value: function animateColumns(column) {
        var millercolumns = this;
        var level = this.getLevel(column);
        var depth = this.depth;

        if (level >= depth - 1) {
          var selectors = [];

          for (var i = 1; i < level; i++) {
            selectors.push('[data-level=\'' + i.toString() + '\']');
          }

          var lists = millercolumns.querySelectorAll(selectors.join(', '));
          var _iteratorNormalCompletion8 = true;
          var _didIteratorError8 = false;
          var _iteratorError8 = undefined;

          try {
            for (var _iterator8 = lists[Symbol.iterator](), _step8; !(_iteratorNormalCompletion8 = (_step8 = _iterator8.next()).done); _iteratorNormalCompletion8 = true) {
              var item = _step8.value;

              item.classList.add('govuk-miller-columns__column--narrow');
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
        }
      }
    }, {
      key: 'resetAnimation',
      value: function resetAnimation(level) {
        var depth = this.depth;

        if (level < depth) {
          var allLists = this.getAllColumns();
          var _iteratorNormalCompletion9 = true;
          var _didIteratorError9 = false;
          var _iteratorError9 = undefined;

          try {
            for (var _iterator9 = allLists[Symbol.iterator](), _step9; !(_iteratorNormalCompletion9 = (_step9 = _iterator9.next()).done); _iteratorNormalCompletion9 = true) {
              var list = _step9.value;

              list.classList.remove('govuk-miller-columns__column--narrow');
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
      }
    }, {
      key: 'list',
      get: function get() {
        var id = this.getAttribute('for');
        if (!id) return;
        var list = document.getElementById(id);
        return list instanceof HTMLUListElement ? list : null;
      }
    }, {
      key: 'breadcrumbs',
      get: function get() {
        var id = this.getAttribute('breadcrumbs');
        if (!id) return;
        var breadcrumbs = document.getElementById(id);
        return breadcrumbs instanceof BreadcrumbsElement ? breadcrumbs : null;
      }
    }, {
      key: 'selectedCheckboxes',
      get: function get() {
        return Array.prototype.slice.call(this.querySelectorAll('input[type=checkbox]:checked'));
      }
    }, {
      key: 'checkboxes',
      get: function get() {
        return Array.prototype.slice.call(this.querySelectorAll('input[type=checkbox]'));
      }
    }, {
      key: 'activeChain',
      get: function get() {
        return Array.prototype.slice.call(this.querySelectorAll('.govuk-miller-columns__column li[data-chain="' + this.dataset.chain + '"]'));
      }
    }, {
      key: 'activeChainIndex',
      get: function get() {
        // $FlowFixMe
        return parseInt(this.dataset.chain);
      }
    }, {
      key: 'depth',
      get: function get() {
        return parseInt(this.dataset.depth);
      }
    }]);

    return MillerColumnsElement;
  }(_CustomElement);

  // A list of selected chains
  var chains = [];

  var BreadcrumbsElement = function (_CustomElement3) {
    _inherits(BreadcrumbsElement, _CustomElement3);

    function BreadcrumbsElement() {
      _classCallCheck(this, BreadcrumbsElement);

      return _possibleConstructorReturn(this, (BreadcrumbsElement.__proto__ || Object.getPrototypeOf(BreadcrumbsElement)).call(this));
    }

    _createClass(BreadcrumbsElement, [{
      key: 'connectedCallback',
      value: function connectedCallback() {
        if (this.millercolumns) {
          this.millercolumns.loadCheckboxes(this.millercolumns.selectedCheckboxes);
        }
        this.renderChains();
      }
    }, {
      key: 'disconnectedCallback',
      value: function disconnectedCallback() {}
    }, {
      key: 'storeActiveChain',
      value: function storeActiveChain() {
        // Store the current chain in a list
        if (this.millercolumns) {
          var index = this.millercolumns.activeChainIndex;
          if (index && this.chain) {
            chains[index] = this.chain;
          }
        }

        // Convert selected items to stored items
        if (Array.isArray(this.chain)) {
          var _iteratorNormalCompletion10 = true;
          var _didIteratorError10 = false;
          var _iteratorError10 = undefined;

          try {
            for (var _iterator10 = this.chain[Symbol.iterator](), _step10; !(_iteratorNormalCompletion10 = (_step10 = _iterator10.next()).done); _iteratorNormalCompletion10 = true) {
              var item = _step10.value;

              item.dataset.selected = 'false';
              item.classList.remove('govuk-miller-columns__item--selected');

              item.dataset.stored = 'true';
              item.classList.add('govuk-miller-columns__item--stored');
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
        }
      }
    }, {
      key: 'swapActiveChain',
      value: function swapActiveChain() {
        // Convert stored items into selected items
        if (Array.isArray(this.chain)) {
          var _iteratorNormalCompletion11 = true;
          var _didIteratorError11 = false;
          var _iteratorError11 = undefined;

          try {
            for (var _iterator11 = this.chain[Symbol.iterator](), _step11; !(_iteratorNormalCompletion11 = (_step11 = _iterator11.next()).done); _iteratorNormalCompletion11 = true) {
              var item = _step11.value;

              item.dataset.selected = 'true';
              item.classList.add('govuk-miller-columns__item--selected');

              item.dataset.stored = 'false';
              item.classList.remove('govuk-miller-columns__item--stored');
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
        }
      }
    }, {
      key: 'updateActiveChain',
      value: function updateActiveChain() {
        if (this.millercolumns) {
          var index = this.millercolumns.activeChainIndex;

          // Store the current chain in a list
          if (this.chain) {
            chains[index] = this.chain;
          }

          // If empty chain remove it from the array
          // $FlowFixMe
          if (chains[index].length === 0) {
            this.removeChain(this, index);
          }
        }

        this.renderChains();
      }
    }, {
      key: 'renderChains',
      value: function renderChains() {
        if (chains.length) {
          this.innerHTML = '';
          var _iteratorNormalCompletion12 = true;
          var _didIteratorError12 = false;
          var _iteratorError12 = undefined;

          try {
            for (var _iterator12 = chains.entries()[Symbol.iterator](), _step12; !(_iteratorNormalCompletion12 = (_step12 = _iterator12.next()).done); _iteratorNormalCompletion12 = true) {
              var _step12$value = _slicedToArray(_step12.value, 2),
                  index = _step12$value[0],
                  chainItem = _step12$value[1];

              // $FlowFixMe
              if (chainItem && chainItem.length) {
                // $FlowFixMe
                this.addChain(chainItem, index);
              }
            }
          } catch (err) {
            _didIteratorError12 = true;
            _iteratorError12 = err;
          } finally {
            try {
              if (!_iteratorNormalCompletion12 && _iterator12.return) {
                _iterator12.return();
              }
            } finally {
              if (_didIteratorError12) {
                throw _iteratorError12;
              }
            }
          }
        } else {
          this.innerHTML = '\n      <ol class="govuk-breadcrumbs__list">\n        <li class="govuk-breadcrumbs__list-item">No selected topics</li>\n      </ol>';
        }
      }
    }, {
      key: 'addChain',
      value: function addChain(chain, index) {
        var chainElement = document.createElement('ol');
        chainElement.classList.add('govuk-breadcrumbs__list');
        chainElement.dataset.chain = index.toString();
        this.updateChain(chainElement, chain);

        // Add a remove link to the chainElement
        var removeButton = document.createElement('button');
        removeButton.dataset.chain = index.toString();
        removeButton.classList.add('govuk-link');
        removeButton.innerHTML = 'Remove topic';
        var fn = this.removeChain.bind(null, this, index);
        removeButton.addEventListener('click', fn, false);

        chainElement.appendChild(removeButton);

        this.appendChild(chainElement);
      }
    }, {
      key: 'updateChain',
      value: function updateChain(chainElement, chain) {
        chainElement.innerHTML = '';
        var _iteratorNormalCompletion13 = true;
        var _didIteratorError13 = false;
        var _iteratorError13 = undefined;

        try {
          for (var _iterator13 = chain[Symbol.iterator](), _step13; !(_iteratorNormalCompletion13 = (_step13 = _iterator13.next()).done); _iteratorNormalCompletion13 = true) {
            var item = _step13.value;

            var breadcrumb = document.createElement('li');

            var label = item.querySelector('label');
            if (label) {
              breadcrumb.innerHTML = label.innerHTML;
            } else {
              breadcrumb.innerHTML = item.innerHTML;
            }

            breadcrumb.classList.add('govuk-breadcrumbs__list-item');
            chainElement.appendChild(breadcrumb);
          }
        } catch (err) {
          _didIteratorError13 = true;
          _iteratorError13 = err;
        } finally {
          try {
            if (!_iteratorNormalCompletion13 && _iterator13.return) {
              _iterator13.return();
            }
          } finally {
            if (_didIteratorError13) {
              throw _iteratorError13;
            }
          }
        }
      }
    }, {
      key: 'removeChain',
      value: function removeChain(breadcrumbs, chainIndex) {
        if (Array.isArray(chains[chainIndex])) {
          breadcrumbs.removeStoredChain(chains[chainIndex]);

          chains.splice(chainIndex, 1);

          // If active chain hide revealed columns
          if (chainIndex === chains.length) {
            if (breadcrumbs.millercolumns) {
              breadcrumbs.millercolumns.hideColumns('2');
            }
          }

          breadcrumbs.renderChains();
        }
      }
    }, {
      key: 'removeStoredChain',
      value: function removeStoredChain(chain) {
        var _iteratorNormalCompletion14 = true;
        var _didIteratorError14 = false;
        var _iteratorError14 = undefined;

        try {
          for (var _iterator14 = chain[Symbol.iterator](), _step14; !(_iteratorNormalCompletion14 = (_step14 = _iterator14.next()).done); _iteratorNormalCompletion14 = true) {
            var item = _step14.value;

            if (this.millercolumns) {
              this.millercolumns.deselectItem(item);
              item.dataset.stored = 'false';
              item.classList.remove('govuk-miller-columns__item--stored');
            }
          }
        } catch (err) {
          _didIteratorError14 = true;
          _iteratorError14 = err;
        } finally {
          try {
            if (!_iteratorNormalCompletion14 && _iterator14.return) {
              _iterator14.return();
            }
          } finally {
            if (_didIteratorError14) {
              throw _iteratorError14;
            }
          }
        }
      }
    }, {
      key: 'millercolumns',
      get: function get() {
        var id = this.getAttribute('for');
        if (!id) return;
        var millercolumns = document.getElementById(id);
        if (!(millercolumns instanceof MillerColumnsElement)) return;
        return millercolumns instanceof MillerColumnsElement ? millercolumns : null;
      }
    }, {
      key: 'chain',
      get: function get() {
        if (!this.millercolumns) return;
        return this.millercolumns.activeChain;
      }
    }]);

    return BreadcrumbsElement;
  }(_CustomElement);

  if (!window.customElements.get('govuk-miller-columns')) {
    window.MillerColumnsElement = MillerColumnsElement;
    window.customElements.define('govuk-miller-columns', MillerColumnsElement);
  }

  if (!window.customElements.get('govuk-breadcrumbs')) {
    window.BreadcrumbsElement = BreadcrumbsElement;
    window.customElements.define('govuk-breadcrumbs', BreadcrumbsElement);
  }

  exports.default = MillerColumnsElement;
});
