/*
 * 2miich - Liiga scores app
 * Copyright (C) 2014 Santtu Lakkala <inz@inz.fi>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Oledify 1.0

import org.nemomobile.dbus 1.0

Oledify {
    id: oledify
    property bool enable: false;
    property bool haveLock: false
    property variant dbusResource: DBusInterface {
        id: tohOled

        destination: 'com.kimmoli.toholed'
        iface: 'com.kimmoli.toholed'
        path: '/'
        busType: DBusInterface.SystemBus
    }

    property variant timer: Timer {
        interval: 25000
        running: enable

        onTriggered: {
            tohOled.typedCallWithReturn("draw", [
                                            {type: 's', value: 'lock'},
                                            {type: 'b', value: enable},
                                            {type: 's', value: 'fi.inz.2miich'}
                                        ],
                                        function (reply) {
                                            var hadLock = haveLock;
                                            haveLock = reply === 'ok';
                                            if (haveLock && !hadLock)
                                                oledify.update();
                                        });

        }
    }

    onEnableChanged: {
        tohOled.typedCallWithReturn("draw", [
                                        {type: 's', value: 'lock'},
                                        {type: 'b', value: enable},
                                        {type: 's', value: 'fi.inz.2miich'}
                                    ],
                                    function (reply) {
                                        var hadLock = haveLock;
                                        haveLock = reply === 'ok';
                                        if (haveLock && !hadLock)
                                            oledify.update();
                                    });
    }

    function update() {
        if (haveLock)
            tohOled.call("drawPicture", [0, 0, oledify.data]);
    }
}
