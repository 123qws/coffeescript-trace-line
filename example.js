(function() {
  var cubes, grade, list, math, num, number, opposite, score, square;

  ide.trace({
    line: 2,
    column: 0,
    type: ''
  });

  number = 42;

  ide.trace({
    line: 3,
    column: 0,
    type: ''
  });

  opposite = true;

  ide.trace({
    line: 4,
    column: 0,
    type: ''
  });

  if (opposite) {
    ide.trace({
      line: 4,
      column: 0,
      type: ''
    });
    number = -42;
  }

  ide.trace({
    line: 7,
    column: 0,
    type: ''
  });

  score = 83;

  ide.trace({
    line: 8,
    column: 0,
    type: ''
  });

  grade = (function() {
    switch (false) {
      case !(score < 80):
        ide.trace({
          line: 9,
          column: 23,
          type: ''
        });
        return 'C';
      case !(score < 90):
        ide.trace({
          line: 10,
          column: 23,
          type: ''
        });
        return 'B';
      default:
        ide.trace({
          line: 11,
          column: 7,
          type: ''
        });
        return 'A';
    }
  })();

  ide.trace({
    line: 14,
    column: 0,
    type: ''
  });

  square = function(x) {
    ide.trace({
      line: 14,
      column: 9,
      type: 'enter'
    });
    try {
      ide.trace({
        line: 14,
        column: 16,
        type: ''
      });
      return x * x;
    } finally {
      ide.trace({
        line: 14,
        column: 9,
        type: 'exit'
      });
    }
  };

  ide.trace({
    line: 15,
    column: 0,
    type: ''
  });

  list = [1];

  ide.trace({
    line: 16,
    column: 0,
    type: ''
  });

  math = {
    root: Math.sqrt,
    square: square,
    cube: function(x) {
      ide.trace({
        line: 19,
        column: 10,
        type: 'enter'
      });
      try {
        ide.trace({
          line: 19,
          column: 17,
          type: ''
        });
        return x * square(x);
      } finally {
        ide.trace({
          line: 19,
          column: 10,
          type: 'exit'
        });
      }
    }
  };

  ide.trace({
    line: 20,
    column: 0,
    type: ''
  });

  cubes = ((function() {
    var i, len, results;
    ide.trace({
      line: 20,
      column: 9,
      type: ''
    });
    results = [];
    for (i = 0, len = list.length; i < len; i++) {
      num = list[i];
      ide.trace({
        line: 20,
        column: 9,
        type: ''
      });
      results.push(math.cube(num));
    }
    return results;
  })());

}).call(this);

