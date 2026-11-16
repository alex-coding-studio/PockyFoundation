#if os(iOS)
    import CoreGraphics
    import PockyFoundation
    import Testing

    struct PKYGridPlacementRoleTests {
        @Test("Grid placement preserves its column and spacing policies")
        func phonePortraitColumns() {
            for phone: CGFloat in [375, 393, 402, 440] {
                let device = PKYGridPlacementRole.Device(
                    portraitWidth: phone,
                    availableWidth: phone,
                    isLarge: false
                )
                #expect(columns(.tile(captioned: false), width: phone, device: device) == 3)
                #expect(columns(.tile(captioned: true), width: phone, device: device) == 3)
                #expect(columns(.folder, width: phone, device: device) == 2)
                #expect(columns(.card, width: phone, device: device) == 1)
            }
        }

        @Test("Grid placement preserves its column and spacing policies")
        func largePortraitColumnsFollowTheDevice() {
            for (portrait, landscape) in [(CGFloat(820), CGFloat(1180)), (1032, 1376)] {
                let upright = PKYGridPlacementRole.Device(
                    portraitWidth: portrait,
                    availableWidth: portrait,
                    isLarge: true
                )
                for sidebar: CGFloat in [0, 40] {
                    for role in [
                        PKYGridPlacementRole.tile(captioned: false),
                        .tile(captioned: true),
                    ] {
                        #expect(columns(
                            role,
                            width: portrait,
                            device: upright,
                            leadingInset: sidebar
                        ) == 5)
                    }
                }
                let sideways = PKYGridPlacementRole.Device(
                    portraitWidth: portrait,
                    availableWidth: landscape,
                    isLarge: true
                )
                #expect(columns(.tile(captioned: false), width: landscape, device: sideways) > 5)
            }
        }

        private func columns(
            _ role: PKYGridPlacementRole,
            width: CGFloat,
            device: PKYGridPlacementRole.Device,
            leadingInset: CGFloat = 0
        ) -> Int {
            let padding = PKYEdgeInsets(
                top: 0,
                leading: role.margin + leadingInset,
                bottom: 0,
                trailing: role.margin
            )
            return role.resolve(width: width, device: device, padding: padding).columns
        }
    }
#endif
