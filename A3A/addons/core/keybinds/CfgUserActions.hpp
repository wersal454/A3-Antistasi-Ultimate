#define ACTIONINTERNAL(type) "["##type##", _this] call A3A_fnc_keyActions"
#define ACTION(type) ACTIONINTERNAL(QGVAR(type))
class CfgUserActions {
    class GVAR(battleMenu) {
        displayName = $STR_A3A_keyActions_battleMenu_title;
        tooltip = $STR_A3A_keyActions_battleMenu_desc;
        onActivate = ACTION(battleMenu);
    };

    class GVAR(artyMenu) {
        displayName = $STR_A3A_keyActions_artyMenu_title;
        tooltip = $STR_A3A_keyActions_artyMenu_desc;
        onActivate = ACTION(artyMenu);
    };

    class GVAR(infoBar) {
        displayName = $STR_A3A_keyActions_infoBar_title;
        tooltip = $STR_A3A_keyActions_infoBar_desc;
        onActivate = ACTION(infoBar);
    };

    class GVAR(earPlugs) {
        displayName = $STR_A3A_keyActions_earPlugs_title;
        tooltip = $STR_A3A_keyActions_earPlugs_desc;
        onActivate = ACTION(earPlugs);
    };

    class GVAR(customHintDismiss) {
        displayName = $STR_A3A_keyActions_customHintDismiss_title;
        tooltip = $STR_A3A_keyActions_customHintDismiss_desc;
        onActivate = ACTION(customHintDismiss);
    };

    class GVAR(commanderRebelMenu) {
        displayName = $STR_A3A_keyActions_commMenu_title;
        tooltip = $STR_A3A_keyActions_commMenu_desc;
        onActivate = ACTION(commanderRebelMenu);
    };
};
#undef ACTION
