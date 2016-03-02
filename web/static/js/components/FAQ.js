import React from 'react';

export default class FAQ extends React.Component {
  render() {
    return (
      <div>
        <h1>
          Frequently Asked Questions
        </h1>
        <h2>
          How does osu! Group Stats work?
        </h2>
        <p>
          Once per day, the osu! API is used to grab a snapshot of each player's stats in each group. These stats include playcount, performance points, PP rank, and more.
        </p>
        <h2>
          I recently created a group. Why is there nothing in the 1/7/30-day changes columns under the Players tab?
        </h2>
        <p>
          These columns require snapshots that go back 1/7/30 days. This means that a group will not have 7-day changes available until the group is at least 7 days old. The same goes for 30-day changes not being available until the group is at least 30 days old.
        </p>
      </div>
    );
  }
}
