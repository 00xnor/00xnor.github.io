const trail_plot_div = document.querySelector('#trail_plot_div');
var filename = trail_plot_div.dataset.filename || 'default.csv';
var plot_name = trail_plot_div.dataset.plot_name || 'some trail :)';


//------------------------------------------------------------------------------
var width  = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
var height = window.innerHeight|| document.documentElement.clientHeight|| document.body.clientHeight;


//------------------------------------------------------------------------------
Plotly.d3.csv(filename, function(err, rows) {
  function unpack(rows, key) { return rows.map(function(row) { return row[key]; }); }
          
  var x = unpack(rows , 'lon');
  var y = unpack(rows , 'lat');
  var z = unpack(rows , 'alt');
  var dist = unpack(rows , 'dist');
  // var color = new Array(dist.length);

  // var black = '#000000';
  // var white = '#ffffff';
  // const muted_blue = '#1f77b4';
  // const safety_orage = '#ff7f0e';
  // const cooked_asparagus_green = '#2ca02c';
  // const brick_red = '#d62728';
  // const muted_purple = '#9467bd';
  // const chestnut_brown = '#8c564b';
  // const raspberry_yogurt_pink = '#e377c2';
  // const middle_gray = '#7f7f7f';
  // const curry_yellow_green = '#bcbd22';
  // const blue_teal = '#17becf';
  const camel = '#be9d6a';
  const navy_blue = '#242459';

  // for (var i = 0; i < dist.length; i++) {
  //   for (var j = 0; j < 26; j++) {
  //     if (dist[i] > j*1609 && dist[i] <= (j+1)*1609) {
  //       if (j % 2 == 0) {
  //         color[i] = navy_blue;
  //       } else {
  //         color[i] = navy_blue;
  //       }
  //     }
  //   }
  // }

  const points_per_line = 10;
  const skip_data_points = 130;
  var num_vertical_lines = parseInt(x.length/skip_data_points);
  var lines_x = new Array(num_vertical_lines);
  var lines_y = new Array(num_vertical_lines);
  var lines_z = new Array(num_vertical_lines);

  for (var i = 0; i < num_vertical_lines; i++) {
    lines_x[i] = new Array(points_per_line);
    lines_y[i] = new Array(points_per_line);
    lines_z[i] = new Array(points_per_line);

    var current_z = z[i*skip_data_points];
    var z_inc = (current_z-Math.min(...z))/points_per_line;

    for (var j = 0; j < points_per_line; j++) {
      lines_x[i][j] = x[i*skip_data_points];
      lines_y[i][j] = y[i*skip_data_points];

      if (j == 0) {
        lines_z[i][j] = Math.min(...z);
      } else {
        lines_z[i][j] = Math.min(...z)+(j+1)*z_inc;
      }
    }
  }

  trace1 = {
    type: 'scatter3d',
    mode: 'lines',
    x: x,
    y: y,
    z: z,
    hoverinfo: 'skip',
    opacity: 1,
    line: {
      width: 5,
      reversescale: false,
      color: navy_blue
    },
    hoverinfo: 'skip'
  };

  trace2 = {
    type: 'scatter3d',
    mode: 'lines',
    x: x,
    y: y,
    z: new Array(x.length).fill(Math.min(...z)),
    line: {
      dash: 'dot',
      width: 1,
      reversescale: false,
      color: 'rgb(0,0,0)',
    },
    hoverinfo: 'skip'
  };

  var trace3 = {
    x: [x[0]],
    y: [y[0]],
    z: [z[0]],
    mode: 'markers',
    marker: {
      color: 'green',
      size: 6,
      symbol: 'circle',
      opacity: 0.8
    },
    type: 'scatter3d',
    hoverinfo: 'skip'
  };

  var trace4 = {
    x: [x[x.length-1]],
    y: [y[y.length-1]],
    z: [z[z.length-1]],
    mode: 'markers',
    marker: {
      color: 'red',
      size: 6,
      symbol: 'circle',
      opacity: 0.8
    },
    type: 'scatter3d',
    hoverinfo: 'skip'
  };

  var data = [trace1];
  data.push(trace2);
  data.push(trace3);
  data.push(trace4);

  for (var i = 0; i < num_vertical_lines; i++) {
    data.push({
      type: 'scatter3d',
      mode: 'lines',
      x: lines_x[i],
      y: lines_y[i],
      z: lines_z[i],
      line: {
        dash: 'dot',
        width: 1,
        reversescale: false,
        color: 'rgb(0,0,0)',
      },
      hoverinfo: 'skip'
    });
  }

  if (width > 718) { width = 718; }
  if (height > 680) { height = 680; }

  Plotly.plot('trail_plot_div', data, {
      paper_bgcolor: 'rgba(0,0,0,0)',
      plot_bgcolor: 'rgba(0,0,0,0)',
      height: height,
      width: width,
      scene: {
        xaxis: { 
          title: '', 
          showticklabels: false, 
          showgrid: false,
          range: [0,1],
          showspikes: false,
        },
        yaxis: {
          title: '', 
          showticklabels: false, 
          showgrid: false,
          range: [0,1],
          showspikes: false,
        },
        zaxis: {
          title: 'elevation (feet)',
          backgroundcolor: 'rgb(211,211,211)',
          showbackground: false,
          zerolinecolor: 'rgb(255, 255, 255)',
          range: [Math.min(...z), Math.max(...z)],
          showspikes: false,
        },
      },
      title: plot_name,
      showlegend: false,
      legend: {'orientation': 'h'}
    }, {
      displayModeBar: false, 
      // scrollZoom: false
    },
  );

  if(window.attachEvent) {
    window.attachEvent('onresize', function() {
      alert('attachEvent - resize');
    });
  }
  else if(window.addEventListener) {
    window.addEventListener('resize', function() {
      if (width > 718) {
        width = 718;
      }

      if (height > 680) {
        height = 680;
      }
    }, true);
  }
  else {
    // the browser doesn't support js event binding
  }

  Plotly.relayout('trail_plot_div', {
    width: width,
    height: height
  });

});


