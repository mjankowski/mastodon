import { InfoIcon } from '@phosphor-icons/react';
import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn } from 'storybook/test';

import { Button } from '../button';

import type { CalloutProps } from './redesign';
import { Callout } from './redesign';

const meta = {
  title: 'Redesign/Callout',
  render({ hasIcon, actionText, secondaryActionText, ...props }) {
    const actionClick = fn().mockName('actionClick');
    const secondaryActionClick = fn().mockName('secondaryActionClick');
    return (
      <Callout
        {...props}
        icon={hasIcon ? InfoIcon : undefined}
        actions={
          <>
            {actionText && (
              <Button size='sm' onClick={actionClick}>
                {actionText}
              </Button>
            )}
            {props.size !== 'sm' && secondaryActionText && (
              <Button size='sm' onClick={secondaryActionClick}>
                {secondaryActionText}
              </Button>
            )}
          </>
        }
      />
    );
  },
  args: {
    children: 'Main text goes here',
    actionText: 'Action 1',
    secondaryActionText: 'Action 2',
    hasIcon: false,
  },
  argTypes: {
    children: { control: 'text' },
    size: { control: 'inline-radio', options: ['sm', 'lg'] },
    actionText: { control: 'text' },
    secondaryActionText: { control: 'text', if: { arg: 'size', neq: 'sm' } },
    hasIcon: { control: 'boolean', if: { arg: 'size', neq: 'sm' } },
  },
} satisfies Meta<
  CalloutProps<React.ElementType> & {
    as?: never;
    hasIcon?: boolean;
    actionText?: string;
    secondaryActionText?: string;
    children: string;
  }
>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Large: Story = {
  args: {
    size: 'lg',
    hasIcon: true,
  },
};

export const Small: Story = { args: { size: 'sm' } };
