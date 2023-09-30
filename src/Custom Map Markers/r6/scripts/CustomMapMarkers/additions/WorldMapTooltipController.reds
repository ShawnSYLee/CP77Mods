import Codeware.Localization.*
import CustomMarkers.Config.*

// Set custom data for worldmap mappin popup

// @addField(WorldMapTooltipController)
// private let m_customInputIcon: ref<inkImage>;

// @addField(WorldMapTooltipController)
// private let m_customInputText: ref<inkText>;

// @wrapMethod(WorldMapTooltipController)
// protected cb func OnInitialize() -> Bool {
//   wrappedMethod();
//   let root: ref<inkCompoundWidget> = this.GetRootCompoundWidget();
//   this.m_customInputIcon = root.GetWidgetByPath(inkWidgetPath.Build(n"tooltip", n"tooltipFlex", n"mainLayout", n"inputs", n"JournalInputDisplayController", n"inputIcon")) as inkImage;
//   this.m_customInputText = root.GetWidgetByPath(inkWidgetPath.Build(n"tooltip", n"tooltipFlex", n"mainLayout", n"inputs", n"JournalInputDisplayController", n"text")) as inkText;
// }

@wrapMethod(WorldMapTooltipController)
public func SetData(const data: script_ref<WorldMapTooltipData>, menu: ref<WorldMapMenuGameController>) -> Void {
  wrappedMethod(data, menu);

  // CUSTOM
  let mappinData: ref<GameplayRoleMappinData>;
  let newTitleStr: String;
  let newDescStr: String;
  if Deref(data).controller != null && Deref(data).mappin != null && menu.GetPlayer() != null {
    mappinData = Deref(data).mappin.GetScriptData() as GameplayRoleMappinData;
    if IsDefined(mappinData) && mappinData.m_isMappinCustom {
      // Set title and description
      newTitleStr = mappinData.m_customMappinTitle;
      newDescStr = mappinData.m_customMappinDescription;
      inkTextRef.SetText(this.m_titleText, newTitleStr);
      inkTextRef.SetText(this.m_descText, newDescStr);
      // TODO
      // Set Delete hint
      // this.m_customInputIcon.SetTexturePart(n"mouse_scroll_hold");
      // this.m_customInputIcon.SetAtlasResource(r"base\\gameplay\\gui\\common\\input\\icons_keyboard.inkatlas");
      // this.m_customInputText.SetText(LocalizationSystem.GetInstance(menu.GetPlayer().GetGame()).GetText("CustomMarkers-ButtonLabelDelete"));
      // inkWidgetRef.SetVisible(this.m_inputOpenJournalContainer, true);
    };
  };
}
