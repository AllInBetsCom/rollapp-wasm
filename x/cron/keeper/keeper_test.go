package keeper_test

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
	chain "github.com/dymensionxyz/rollapp-wasm/app"
	"github.com/dymensionxyz/rollapp-wasm/x/cron/keeper"
	"github.com/dymensionxyz/rollapp-wasm/x/cron/types"
	"github.com/stretchr/testify/suite"
	tmproto "github.com/tendermint/tendermint/proto/tendermint/types"
	"testing"
)

type KeeperTestSuite struct {
	suite.Suite
	app       *chain.App
	ctx       sdk.Context
	keeper    keeper.Keeper
	querier   keeper.QueryServer
	msgServer types.MsgServer
}

func TestKeeperTestSuite(t *testing.T) {
	suite.Run(t, new(KeeperTestSuite))
}

func (s *KeeperTestSuite) SetupTest() {
	s.app = chain.Setup(s.T(), false)
	s.ctx = s.app.BaseApp.NewContext(false, tmproto.Header{})
	s.keeper = s.app.CronKeeper
	s.querier = keeper.QueryServer{Keeper: s.keeper}
	s.msgServer = keeper.NewMsgServerImpl(s.keeper)
}
