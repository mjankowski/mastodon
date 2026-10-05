import { Map as ImmutableMap, List as ImmutableList } from 'immutable';

import { STORE_HYDRATE } from '../actions/store';

/** @type {ImmutableMap<string, unknown>} */
const initialState = ImmutableMap({
  accept_content_types: ImmutableList(),
});

export default function meta(state = initialState, action) {
  switch(action.type) {
  case STORE_HYDRATE:
    return state.merge(action.state.get('media_attachments'));
  default:
    return state;
  }
}
