#!/usr/bin/env python3

# Testing if layered charts work in streamlit. Showing up blank for me.
# This example is from: 
#   https://github.com/streamlit/streamlit/issues/1667

import altair as alt
from altair.expr import datum
from vega_datasets import data
import streamlit as st

stocks = data.stocks.url

base = alt.Chart(stocks).encode(
    x='date:T',
    y='price:Q',
    color='symbol:N'
).transform_filter(
    datum.symbol == 'GOOG'
)

st.write((base.mark_line() + base.mark_point()).resolve_scale(y='independent')) # works
st.altair_chart((base.mark_line() + base.mark_point()).resolve_scale(y='independent')) # works

