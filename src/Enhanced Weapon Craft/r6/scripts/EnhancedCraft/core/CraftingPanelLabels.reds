module EnhancedCraft.UI
import EnhancedCraft.Common.L
import EnhancedCraft.Config.*

@addField(CraftingLogicController)
private let m_availableSkinsText: ref<inkText>;

@addField(CraftingLogicController)
private let m_randomizerText: ref<inkText>;

@wrapMethod(CraftingLogicController)
public func Init(craftingGameController: wref<CraftingMainGameController>) -> Void {
  wrappedMethod(craftingGameController);

  let root: ref<inkCompoundWidget> = this.GetRootCompoundWidget();
  let textContainer: ref<inkCompoundWidget> = root.GetWidget(n"inkCanvasWidget2/itemDetailsContainer/weaponPreviewContainer") as inkCompoundWidget;
  
  if !IsDefined(this.m_availableSkinsText) || NotEquals(this.m_availableSkinsText.GetName(), n"AvailableSkinsLabel") {
    this.m_availableSkinsText = new inkText();
    this.m_availableSkinsText.SetName(n"AvailableSkinsLabel");
    this.m_availableSkinsText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    this.m_availableSkinsText.SetFontStyle(inkTextRef.GetFontStyle(this.m_perkNotificationText));
    this.m_availableSkinsText.SetFontSize(inkTextRef.GetFontSize(this.m_perkNotificationText));
    this.m_availableSkinsText.SetHAlign(inkEHorizontalAlign.Left);
    this.m_availableSkinsText.SetVAlign(inkEVerticalAlign.Bottom);
    this.m_availableSkinsText.SetAnchor(inkEAnchor.BottomLeft);
    this.m_availableSkinsText.SetAnchorPoint(0.0, 1.0);
    this.m_availableSkinsText.SetMargin(new inkMargin(50.0, 0.0, 0.0, 65.0));
    this.m_availableSkinsText.SetLetterCase(textLetterCase.UpperCase);
    this.m_availableSkinsText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
    this.m_availableSkinsText.BindProperty(n"tintColor", n"MainColors.Red");
    this.m_availableSkinsText.Reparent(textContainer);
  };

  if !IsDefined(this.m_randomizerText) || NotEquals(this.m_randomizerText.GetName(), n"RandomizerLabel") {
    this.m_randomizerText = new inkText();
    this.m_randomizerText.SetName(n"AvailableSkinsLabel");
    this.m_randomizerText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    this.m_randomizerText.SetFontStyle(inkTextRef.GetFontStyle(this.m_perkNotificationText));
    this.m_randomizerText.SetFontSize(inkTextRef.GetFontSize(this.m_perkNotificationText));
    this.m_randomizerText.SetHAlign(inkEHorizontalAlign.Left);
    this.m_randomizerText.SetVAlign(inkEVerticalAlign.Bottom);
    this.m_randomizerText.SetAnchor(inkEAnchor.BottomLeft);
    this.m_randomizerText.SetAnchorPoint(0.0, 1.0);
    this.m_randomizerText.SetMargin(new inkMargin(50.0, 0.0, 0.0, 20.0));
    this.m_randomizerText.SetLetterCase(textLetterCase.UpperCase);
    this.m_randomizerText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
    this.m_randomizerText.BindProperty(n"tintColor", n"MainColors.Red");
    this.m_randomizerText.Reparent(textContainer);
  };
}

@addMethod(CraftingLogicController)
public func RefreshSkinsCounter() -> Void {
  let size: Int32 = ArraySize(this.m_weaponVariants);
  if size > 1 {
    this.m_availableSkinsText.SetVisible(true);
    this.m_availableSkinsText.SetText(s"\(GetLocalizedTextByKey(n"Mod-Craft-UI-Variants")) \(size)");
  } else {
    this.m_availableSkinsText.SetVisible(false);
  };
}

@addMethod(CraftingLogicController)
public func RefreshRandomizerLabel() -> Void {
  if ArraySize(this.m_weaponVariants) > 1 {
    this.m_randomizerText.SetVisible(true);
    if Config.RandomizerEnabled() {
      this.m_randomizerText.SetText(GetLocalizedTextByKey(n"Mod-Craft-UI-Randomizer-Enabled"));
    } else {
      this.m_randomizerText.SetText(GetLocalizedTextByKey(n"Mod-Craft-UI-Randomizer-Disabled"));
    };
  } else {
    this.m_randomizerText.SetVisible(false);
  };
}