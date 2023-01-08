module Sleeves

private class SleevesConfig {

  // Equipment exclusion list
  public static func Exclude(itemID: ItemID) -> Bool {
    let id: TweakDBID = ItemID.GetTDBID(itemID);
    return
      // You can add item records below:
      Equals(id, t"Items.Q101_Recovery_Bandage_Outfit") ||  // Bandage Wrapping
      Equals(id, t"Items.Jacket_01_basic_02") ||            // Biker Vibe Composite-Lined Crystaljock Bomber
      Equals(id, t"Items.SQ030_Diving_Suit") ||             // Judy's Diving Suit
      Equals(id, t"Items.sq030_diving_suit_female") ||      // Judy's Diving Suit
      Equals(id, t"Items.sq030_diving_suit_male") ||        // Judy's Diving Suit
      Equals(id, t"Items.SQ030_Diving_Suit_NoShoes") ||     // Judy's Diving Suit
      Equals(id, t"Items.MQ049_martinez_jacket") ||         // David's Jacket
      Equals(id, t"Items.nd_alt_jacket_default") ||         // ND Alt's Jacket
      Equals(id, t"Items.nd_alt_jacket_black") ||         // ND Alt's Jacket
      Equals(id, t"Items.nd_alt_jacket_blue") ||         // ND Alt's Jacket
      Equals(id, t"Items.nd_alt_jacket_green") ||         // ND Alt's Jacket
      Equals(id, t"Items.nd_alt_jacket_pink") ||         // ND Alt's Jacket
      Equals(id, t"Items.nd_alt_jacket_red") ||         // ND Alt's Jacket
      Equals(id, t"Items.nd_alt_jacket_white") ||         // ND Alt's Jacket
      Equals(id, t"Items.nd_alt_jacket_burgundy") ||         // ND Alt's Jacket
      Equals(id, t"Items.nd_alt_jacket_brown") ||         // ND Alt's Jacket
      false;
  }

  public static func TargetSlots() -> array<TweakDBID> = [
    t"AttachmentSlots.Torso", 
    t"AttachmentSlots.Chest",
    t"AttachmentSlots.Outfit",
    t"OutfitSlots.TorsoUnder",
    t"OutfitSlots.TorsoInner",
    t"OutfitSlots.TorsoMiddle",
    t"OutfitSlots.TorsoOuter"
  ]

  // Uncomment any line to treat cyberware as incompatible what means that 
  // sleeves will be rolled up if have it installed (no matter equipped or not)
  public static func IncompatibleCyberware() -> array<gamedataItemType> = [
    // gamedataItemType.Cyb_NanoWires,
    // gamedataItemType.Cyb_StrongArms,
    // gamedataItemType.Cyb_Launcher,
    gamedataItemType.Cyb_MantisBlades,
    gamedataItemType.Clo_Face // <- do not edit this one, just utility line to make empty array work
  ]
}

// -- DO NOT EDIT ANYTHING BELOW


public class SleevesControlSystem extends ScriptableSystem {

  private let playerPuppet: wref<PlayerPuppet>;

  private let transactionSystem: wref<TransactionSystem>;

  private let hasLauncher: Bool;

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    this.playerPuppet = GameInstance.GetPlayerSystem(request.owner.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    this.transactionSystem = GameInstance.GetTransactionSystem(request.owner.GetGame());
    this.hasLauncher = false;
  }

  private final func OnPlayerDetach(request: ref<PlayerDetachRequest>) -> Void {
    this.playerPuppet = null;
    this.transactionSystem = null;
  }

  public func SetHasLauncher(value: Bool) -> Void {
    this.hasLauncher = value;
  }

  public func RunAppearanceSwap() -> Void {
    // Check for cyberware
    if this.hasLauncher || this.HasIncompatibleCyberware() {
      this.SwapTargetSlotsToFPP();
    } else {
      this.SwapTargetSlotsToTPP();
    };
  }

  private func SwapItemAppearance(slot: TweakDBID, from: String, to: String) -> Void {
    let itemObject: ref<ItemObject> = this.transactionSystem.GetItemInSlot(this.playerPuppet, slot);
    let itemID: ItemID = itemObject.GetItemID();
    if SleevesConfig.Exclude(itemID) {
      return ;
    };

    let appearanceString: String = ToString(this.transactionSystem.GetItemAppearance(this.playerPuppet, itemID));
    let newAppearanceString: String;
    if StrFindLast(appearanceString, from) != -1 {
      newAppearanceString = StrReplace(appearanceString, from, to);
      this.transactionSystem.ChangeItemAppearanceByName(this.playerPuppet, itemID, StringToName(newAppearanceString));
    };
  }

  // -- Swap item appearance from target slots to FPP variant
  private func SwapTargetSlotsToFPP() -> Void {
    for slot in SleevesConfig.TargetSlots() {
      this.SwapItemAppearance(slot, "&TPP", "&FPP");
    };
  }

  // -- Swap item appearance from target slots to TPP variant
  private func SwapTargetSlotsToTPP() -> Void {
    for slot in SleevesConfig.TargetSlots() {
      this.SwapItemAppearance(slot, "&FPP", "&TPP");
    };
  }

  private final func IsCyberwareTypIncompatible(type: gamedataItemType) -> Bool {
    for target in SleevesConfig.IncompatibleCyberware() {
      if Equals(target, type) {
        return true;
      };
    };

    return false;
  }

  private final func HasIncompatibleCyberware() -> Bool {
    let armsCW: gamedataItemType = RPGManager.GetItemType(EquipmentSystem.GetInstance(this.playerPuppet).GetActiveItem(this.playerPuppet, gamedataEquipmentArea.ArmsCW));
    return this.IsCyberwareTypIncompatible(armsCW);
  }
}

// -- Swap appearance after weapon manipulation requests
@wrapMethod(EquipmentSystemPlayerData)
public final func OnEquipmentSystemWeaponManipulationRequest(request: ref<EquipmentSystemWeaponManipulationRequest>) -> Void {
  wrappedMethod(request);
  let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.m_owner.GetGame());
  let sleevesSystem: ref<SleevesControlSystem> = container.Get(n"Sleeves.SleevesControlSystem") as SleevesControlSystem;
  sleevesSystem.RunAppearanceSwap();
}

// -- Swap appearance after entAppearanceChangeFinishEvent events
@addField(PlayerPuppet)
private let m_sleevesControlSystem: ref<SleevesControlSystem>;

@wrapMethod(PlayerPuppet)
private final func PlayerAttachedCallback(playerPuppet: ref<GameObject>) -> Void {
  wrappedMethod(playerPuppet);
  this.m_sleevesControlSystem = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"Sleeves.SleevesControlSystem") as SleevesControlSystem;
}

@wrapMethod(PlayerPuppet)
protected cb func OnAppearanceChangeFinishEvent(evt: ref<entAppearanceChangeFinishEvent>) -> Bool {
  wrappedMethod(evt);
  this.m_sleevesControlSystem.RunAppearanceSwap();
}

// -- Cyberware helper methods

@addMethod(UpperBodyTransition)
public final static func HasLauncherEquipped(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  let weapon: ref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
  let armsCW: gamedataItemType = RPGManager.GetItemType(EquipmentSystem.GetInstance(scriptInterface.executionOwner).GetActiveItem(scriptInterface.executionOwner, gamedataEquipmentArea.ArmsCW));
  let weaponType: gamedataItemType;
  if IsDefined(weapon) {
    weaponType = scriptInterface.GetTransactionSystem().GetItemData(scriptInterface.executionOwner, weapon.GetItemID()).GetItemType();
    if Equals(weaponType, gamedataItemType.Wea_Fists) && Equals(armsCW, gamedataItemType.Cyb_Launcher) {
      return true;
    };
  };
  return false;
}

@addMethod(UpperBodyTransition)
public final static func HasCyberwareEquipped(const scriptInterface: ref<StateGameScriptInterface>, type: gamedataItemType) -> Bool {
  let weapon: ref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
  let weaponType: gamedataItemType;
  if IsDefined(weapon) {
    weaponType = scriptInterface.GetTransactionSystem().GetItemData(scriptInterface.executionOwner, weapon.GetItemID()).GetItemType();
    if Equals(weaponType, type) {
      return true;
    };
  };
  return false;
}


// -- Run appearance swap on weapon transitions

@addMethod(UpperBodyEventsTransition)
private func UpdateCyberwareState(scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(scriptInterface.executionOwner.GetGame());
  let sleevesSystem: ref<SleevesControlSystem> =  container.Get(n"Sleeves.SleevesControlSystem") as SleevesControlSystem;
  let launcher: Bool = UpperBodyTransition.HasLauncherEquipped(scriptInterface);
  sleevesSystem.SetHasLauncher(launcher);
  sleevesSystem.RunAppearanceSwap();
}

@wrapMethod(UpperBodyEventsTransition)
protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  this.UpdateCyberwareState(scriptInterface);
}

@wrapMethod(UpperBodyEventsTransition)
protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  this.UpdateCyberwareState(scriptInterface);
}

public class DelayedSleevesCallback extends DelayCallback {
  let sleevesSystem: ref<SleevesControlSystem>;
  public func Call() -> Void {
    this.sleevesSystem.RunAppearanceSwap();
  }
}

@addField(VehicleComponent)
private let m_delayId: DelayID;

@addField(VehicleComponent)
private let m_delaySystem: ref<DelaySystem>;

@addField(VehicleComponent)
private let m_sleevesControlSystem: ref<SleevesControlSystem>;

@wrapMethod(VehicleComponent)
private final func OnGameAttach() -> Void {
  wrappedMethod();
  this.m_delaySystem = GameInstance.GetDelaySystem(this.GetVehicle().GetGame());
  this.m_sleevesControlSystem = GameInstance.GetScriptableSystemsContainer(this.GetVehicle().GetGame()).Get(n"Sleeves.SleevesControlSystem") as SleevesControlSystem;
}

@wrapMethod(VehicleComponent)
protected final func OnVehicleCameraChange(state: Bool) -> Void {
  wrappedMethod(state);

  let callback: ref<DelayedSleevesCallback> = new DelayedSleevesCallback();
  callback.sleevesSystem = this.m_sleevesControlSystem;
  this.m_delaySystem.CancelCallback(this.m_delayId);
  this.m_delayId = this.m_delaySystem.DelayCallback(callback, 2.0);
}
