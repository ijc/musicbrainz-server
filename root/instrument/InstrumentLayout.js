/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import InstrumentSidebar
  from '../layout/components/sidebar/InstrumentSidebar';
import localizeInstrumentName
  from '../static/scripts/common/i18n/localizeInstrumentName';

import InstrumentHeader from './InstrumentHeader';

type Props = {
  +$c: CatalystContextT,
  +children: React.Node,
  +entity: InstrumentT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const InstrumentLayout = ({
  $c,
  children,
  entity: instrument,
  fullWidth,
  page,
  title,
}: Props): React.Element<typeof Layout> => {
  const nameWithType = texp.l('{type} “{instrument}”', {
    instrument: localizeInstrumentName(instrument),
    type: instrument.typeName
      ? lp_attributes(instrument.typeName, 'instrument_type')
      : l('Instrument'),
  });
  return (
    <Layout
      $c={$c}
      title={title
        ? hyphenateTitle(nameWithType, title)
        : nameWithType}
    >
      <div id="content">
        <InstrumentHeader instrument={instrument} page={page} />
        {children}
      </div>
      {fullWidth ? null : (
        <InstrumentSidebar $c={$c} instrument={instrument} />
      )}
    </Layout>
  );
};

export default InstrumentLayout;
