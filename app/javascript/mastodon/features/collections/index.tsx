import { defineMessages, useIntl } from 'react-intl';
import type { NoMessageValues, MessageValue } from 'react-intl';

import classNames from 'classnames';
import { Route, Switch, useRouteMatch } from 'react-router-dom';

import { Helmet } from '@unhead/react/helmet';

import { Column } from '@/mastodon/components/column';
import { ColumnHeader as LegacyColumnHeader } from '@/mastodon/components/column/header';
import { ColumnHeader } from '@/mastodon/components/column_header';
import { NavigationFocusTarget } from '@/mastodon/components/navigation_focus_target';
import { isRedesignEnabled } from '@/mastodon/utils/environment';
import { DisplayNameSimple } from 'mastodon/components/display_name/simple';
import { Scrollable } from 'mastodon/components/scrollable_list/components';
import { TabLink, TabList } from 'mastodon/components/tab_list';
import { useAccount } from 'mastodon/hooks/useAccount';
import { useAccountId, useCurrentAccountId } from 'mastodon/hooks/useAccountId';

import { CollectionsCreatedByAccount } from './overview/created_by_account';
import { CollectionsFeaturingYou } from './overview/featuring_you';
import classes from './styles.module.scss';

const messages = defineMessages<{
  readonly headingMe: NoMessageValues;
  readonly headingOther: { readonly name: MessageValue };
  readonly createdByYou: NoMessageValues;
  readonly createdByAuthor: { readonly name: MessageValue };
  readonly featuringYou: NoMessageValues;
}>({
  headingMe: {
    id: 'column.your_collections',
    defaultMessage: 'Your Collections',
  },
  headingOther: {
    id: 'column.other_collections',
    defaultMessage: "{name}'s Collections",
  },
  createdByYou: {
    id: 'collections.list.created_by_you',
    defaultMessage: 'Created by you',
  },
  createdByAuthor: {
    id: 'collections.list.created_by_author',
    defaultMessage: 'Created by {name}',
  },
  featuringYou: {
    id: 'collections.list.featuring_you',
    defaultMessage: 'Featuring you',
  },
});

export const Collections: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const intl = useIntl();
  const me = useCurrentAccountId();
  const accountId = useAccountId();
  const account = useAccount(accountId);
  const { path } = useRouteMatch();

  const isOwnCollectionsPage = accountId === me;

  const pageTitle = isOwnCollectionsPage
    ? intl.formatMessage(messages.headingMe)
    : intl.formatMessage(messages.headingOther, {
        name: account?.get('display_name'),
      });
  const pageTitleHtml = isOwnCollectionsPage
    ? intl.formatMessage(messages.headingMe)
    : intl.formatMessage(messages.headingOther, {
        name: <DisplayNameSimple account={account} />,
      });

  return (
    <Column bindToDocument={!multiColumn} label={pageTitle}>
      {isRedesignEnabled() ? (
        <ColumnHeader title={pageTitle} />
      ) : (
        <LegacyColumnHeader showBackButton multiColumn={multiColumn} />
      )}

      <Scrollable>
        <header
          className={classNames(
            classes.header,
            isRedesignEnabled() && classes.headerRedesign,
          )}
        >
          {!isRedesignEnabled() && (
            <NavigationFocusTarget as='h1' className={classes.heading}>
              {pageTitleHtml}
            </NavigationFocusTarget>
          )}
          <TabList plain>
            <TabLink exact to={`/@${account?.acct}/collections`}>
              {isOwnCollectionsPage
                ? intl.formatMessage(messages.createdByYou)
                : intl.formatMessage(messages.createdByAuthor, {
                    name: <DisplayNameSimple account={account} />,
                  })}
            </TabLink>
            {isOwnCollectionsPage && (
              <TabLink
                exact
                to={`/@${account?.acct}/collections/featuring-you`}
              >
                {intl.formatMessage(messages.featuringYou)}
              </TabLink>
            )}
          </TabList>
        </header>
        <Switch>
          <Route exact path={path} component={CollectionsCreatedByAccount} />
          <Route
            exact
            path={`${path}/featuring-you`}
            component={CollectionsFeaturingYou}
          />
        </Switch>
      </Scrollable>

      <Helmet>
        <title>{pageTitle}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};
