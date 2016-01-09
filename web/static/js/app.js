import React, { Component } from 'react'
import RaisedButton from 'material-ui/lib/raised-button';
import Table from 'material-ui/lib/table/table';
import TableBody from 'material-ui/lib/table/table-body';
import TableFooter from 'material-ui/lib/table/table-footer';
import TableHeader from 'material-ui/lib/table/table-header';
import TableHeaderColumn from 'material-ui/lib/table/table-header-column';
import TableRow from 'material-ui/lib/table/table-row';
import TableRowColumn from 'material-ui/lib/table/table-row-column';
import Paper from 'material-ui/lib/paper';


export default class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      beatmaps: [],
      selectedBeatmapIndex: null,
    };
  }

  componentDidMount() {
    const root = location.protocol + '//' + location.host;
    $.get(`${root}/api/farmed-beatmaps`, beatmaps => {
      this.setState({
        beatmaps,
      });
    });
  }

  handleOnRowSelection(selectedRows) {
    if (selectedRows.length === 1) {
      const [ selectedRow ] = selectedRows;
      this.setState({
        selectedBeatmapIndex: selectedRow,
      });
    }
  }

  render() {
    return (
      <div>
        <Paper style={{ display: 'inline-block', width: '800px' }}>
          <Table
            height='500px'
            onRowSelection={this.handleOnRowSelection.bind(this)}>
            <TableHeader
              displaySelectAll={false}>
              <TableRow>
                <TableHeaderColumn style={{ width: '20px' }}>
                  Rank
                </TableHeaderColumn>
                <TableHeaderColumn style={{ width: '20px' }}>
                  # Scores
                </TableHeaderColumn>
                <TableHeaderColumn>
                  Artist
                </TableHeaderColumn>
                <TableHeaderColumn>
                  Title
                </TableHeaderColumn>
                <TableHeaderColumn>
                  Version
                </TableHeaderColumn>
              </TableRow>
            </TableHeader>
            <TableBody>
              {this.state.beatmaps.map((beatmap, index) => {
                return (
                  <TableRow
                    key={index}>
                    <TableRowColumn style={{ width: '20px' }}>
                      {index + 1}
                    </TableRowColumn>
                    <TableRowColumn style={{ width: '20px' }}>
                      {beatmap.scores.length}
                    </TableRowColumn>
                    <TableRowColumn>
                      {beatmap.artist}
                    </TableRowColumn>
                    <TableRowColumn>
                      {beatmap.title}
                    </TableRowColumn>
                    <TableRowColumn>
                      {beatmap.version}
                    </TableRowColumn>
                  </TableRow>
                  );
              })}
            </TableBody>
          </Table>
        </Paper>

        {this.state.selectedBeatmapIndex !== null ?
          (() => {
            const selectedBeatmap = this.state.beatmaps[this.state.selectedBeatmapIndex];

            return (
              <Paper style={{ marginLeft: '50px', width: '520px', display: 'inline-block' }}>
                <Table height='500px'>
                  <TableHeader
                    adjustForCheckbox={false}
                    displaySelectAll={false}>
                    <TableRow>
                      <TableHeaderColumn style={{ width: '20px' }}>
                        Rank
                      </TableHeaderColumn>
                      <TableHeaderColumn style={{ width: '100px' }}>
                        Username
                      </TableHeaderColumn>
                      <TableHeaderColumn style={{ width: '50px' }}>
                        PP
                      </TableHeaderColumn>
                      <TableHeaderColumn>
                        Date
                      </TableHeaderColumn>
                    </TableRow>
                  </TableHeader>
                  <TableBody
                    adjustForCheckbox={false}
                    displayRowCheckbox={false}>
                    {selectedBeatmap.scores.map((score, index) => {
                      const scoreDate = new Date(score.date);
                      return (
                        <TableRow
                          key={index}>
                          <TableRowColumn style={{ width: '20px' }}>
                            {index + 1}
                          </TableRowColumn>
                          <TableRowColumn style={{ width: '100px' }}>
                            {score.user.username}
                          </TableRowColumn>
                          <TableRowColumn style={{ width: '50px' }}>
                            {score.pp}
                          </TableRowColumn>
                          <TableRowColumn>
                            {scoreDate.toLocaleString('en-US')}
                          </TableRowColumn>
                        </TableRow>
                        );
                    })}
                  </TableBody>
                </Table>
              </Paper>
            );
          })()
        : null}
      </div>
    )
  }
}
